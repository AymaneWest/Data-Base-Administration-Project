from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
import oracledb
import logging
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse, FineType
from pydantic import BaseModel

router = APIRouter(prefix="/fines", tags=["Fine Management"])

logger = logging.getLogger("Routes.fine_route")
logger.setLevel(logging.INFO)


# Request/Response Models
class WaiveFineRequest(BaseModel):
    fine_id: int
    waiver_reason: str
    staff_id: int


class WaiveFineResponse(BaseResponse):
    fine_id: Optional[int] = None
    waived_amount: Optional[float] = None


class AssessFineRequest(BaseModel):
    patron_id: int
    loan_id: Optional[int] = None
    fine_type: FineType
    amount: float
    staff_id: int


class AssessFineResponse(BaseResponse):
    fine_id: Optional[int] = None
    amount: Optional[float] = None


# Endpoints
@router.get("/list")
async def get_fines_list(
    status: Optional[str] = None,
    auth: dict = Depends(require_authentication)
):
    """
    Get all fines with optional status filter
    Status can be: Paid, Unpaid, Partially Paid, Waived, or None for all
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    logger.info(f"🔍 Fines list requested by user: {oracle_user}")
    logger.info(f"Status filter: {status if status else 'None (all fines)'}")

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            logger.info("✅ Oracle connection established")
            cursor = conn.cursor()

            try:
                query = """
                    SELECT 
                        f.fine_id,
                        f.patron_id,
                        p.first_name || ' ' || p.last_name as patron_name,
                        p.email as patron_email,
                        p.phone as patron_phone,
                        f.loan_id,
                        m.title as material_title,
                        f.fine_type,
                        f.amount_due as amount,
                        f.amount_paid,
                        (f.amount_due - f.amount_paid) as balance,
                        f.fine_status,
                        TO_CHAR(f.date_assessed, 'YYYY-MM-DD') as issue_date,
                        TO_CHAR(f.payment_date, 'YYYY-MM-DD') as payment_date,
                        f.waiver_reason,
                        b.branch_name
                    FROM FINES f
                    JOIN PATRONS p ON f.patron_id = p.patron_id
                    LEFT JOIN LOANS l ON f.loan_id = l.loan_id
                    LEFT JOIN COPIES c ON l.copy_id = c.copy_id
                    LEFT JOIN MATERIALS m ON c.material_id = m.material_id
                    LEFT JOIN BRANCHES b ON p.registered_branch_id = b.branch_id
                    WHERE 1=1
                """
                
                params = {}
                
                if status:
                    query += " AND UPPER(f.fine_status) = UPPER(:status)"
                    params["status"] = status
                    logger.info(f"Filtering by status: {status}")
                
                query += " ORDER BY f.date_assessed DESC"
                
                logger.debug(f"Executing query with params: {params}")
                cursor.execute(query, params)
                
                rows = cursor.fetchall()
                logger.info(f"🔢 Number of fines found: {len(rows)}")
                
                columns = [col[0].lower() for col in cursor.description]
                results = [dict(zip(columns, row)) for row in rows]
                
                if results:
                    logger.info(f"Sample fine: {results[0]}")
                else:
                    logger.warning("⚠ No fines found in database")
                
                return {
                    "success": True,
                    "count": len(results),
                    "fines": results
                }

            except oracledb.DatabaseError as e:
                logger.error("❌ Database error during fines fetch", exc_info=True)
                error_response = handle_oracle_error(e, oracle_user)
                return {
                    "success": False,
                    "message": "Error fetching fines",
                    "count": 0,
                    "fines": [],
                    **error_response
                }

    except HTTPException:
        logger.warning("⚠ HTTPException raised in get_fines_list")
        raise
    except Exception as e:
        logger.critical("🔥 Unexpected error in get_fines_list", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")



@router.post("/waive", response_model=WaiveFineResponse)
async def waive_fine(
        request: WaiveFineRequest,
        auth: dict = Depends(require_authentication)
):
    """Waive a fine"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_waive_fine", [
                    request.fine_id,
                    request.waiver_reason,
                    request.staff_id
                ])

                return WaiveFineResponse(
                    success=True,
                    message="Fine waived successfully",
                    fine_id=request.fine_id
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return WaiveFineResponse(
                    success=False,
                    message="Error waiving fine",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/assess", response_model=AssessFineResponse)
async def assess_fine(
        request: AssessFineRequest,
        auth: dict = Depends(require_authentication)
):
    """Assess a new fine"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Create OUT parameter for fine ID
                fine_id = cursor.var(int)

                cursor.callproc("sp_assess_fine", [
                    request.patron_id,
                    request.loan_id,
                    request.fine_type.value,
                    request.amount,
                    request.staff_id,
                    fine_id
                ])

                return AssessFineResponse(
                    success=True,
                    message="Fine assessed successfully",
                    fine_id=fine_id.getvalue(),
                    amount=request.amount
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return AssessFineResponse(
                    success=False,
                    message="Error assessing fine",
                    **error_response
                )

    except HTTPException:
        raise