from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
import oracledb
import logging
from datetime import date
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse
from pydantic import BaseModel

router = APIRouter(prefix="/patrons", tags=["Patron Management"])

logger = logging.getLogger("Routes.patron_route")
logger.setLevel(logging.INFO)
# Request/Response Models
class RenewMembershipRequest(BaseModel):
    patron_id: int


class RenewMembershipResponse(BaseResponse):
    new_expiry_date: Optional[str] = None
    patron_id: Optional[int] = None


class SuspendPatronRequest(BaseModel):
    patron_id: int
    reason: str
    staff_id: int


class SuspendPatronResponse(BaseResponse):
    patron_id: Optional[int] = None
    status: Optional[str] = None


class ReactivatePatronRequest(BaseModel):
    patron_id: int
    staff_id: int


class ReactivatePatronResponse(BaseResponse):
    patron_id: Optional[int] = None
    status: Optional[str] = None


# Endpoints
@router.get("/search")
async def search_patrons(
    search_term: str,
    auth: dict = Depends(require_authentication)
):
    """
    Search for patrons by ID, email, or name
    Returns list of matching patrons with basic information
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    logger.info("🔍 Patron search requested")
    logger.info(f"Authenticated Oracle user: {oracle_user}")
    logger.info(f"Search term received: '{search_term}'")

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            logger.info("✅ Oracle connection established")

            cursor = conn.cursor()
            logger.debug("Cursor created")

            try:
                query = """
                    SELECT 
                        p.patron_id,
                        p.card_number,
                        p.first_name,
                        p.last_name,
                        p.email,
                        p.phone,
                        p.address,
                        p.membership_type,
                        p.account_status,
                        TO_CHAR(p.membership_expiry, 'YYYY-MM-DD') AS membership_expiry,
                        b.branch_name
                    FROM PATRONS p
                    LEFT JOIN BRANCHES b
                        ON p.registered_branch_id = b.branch_id
                    WHERE 
                        UPPER(p.email) LIKE UPPER(:search)
                        OR UPPER(p.first_name || ' ' || p.last_name) LIKE UPPER(:search)
                        OR UPPER(p.first_name) LIKE UPPER(:search)
                        OR UPPER(p.last_name) LIKE UPPER(:search)
                        OR (
                            REGEXP_LIKE(:search_raw, '^[0-9]+$')
                            AND p.patron_id = TO_NUMBER(:search_raw)
                        )
                    ORDER BY p.last_name, p.first_name
                    FETCH FIRST 50 ROWS ONLY
                """

                search_pattern = f"%{search_term}%"

                logger.debug("Executing patron search query")
                logger.debug(f"Search pattern: {search_pattern}")

                cursor.execute(query, {
                    "search": search_pattern,
                    "search_raw": search_term
                })

                rows = cursor.fetchall()
                logger.info(f"🔢 Number of patrons found: {len(rows)}")

                columns = [col[0].lower() for col in cursor.description]
                results = [dict(zip(columns, row)) for row in rows]

                logger.debug("Patron search results prepared successfully")

                return {
                    "success": True,
                    "count": len(results),
                    "patrons": results
                }

            except oracledb.DatabaseError as e:
                logger.error("❌ Database error during patron search", exc_info=True)
                error_response = handle_oracle_error(e, oracle_user)

                return {
                    "success": False,
                    "message": "Error searching patrons",
                    "count": 0,
                    "patrons": [],
                    **error_response
                }

    except HTTPException:
        logger.warning("⚠ HTTPException raised in search_patrons")
        raise

    except Exception as e:
        logger.critical("🔥 Unexpected error in search_patrons", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")




@router.post("/renew-membership", response_model=RenewMembershipResponse)
async def renew_membership(
        request: RenewMembershipRequest,
        auth: dict = Depends(require_authentication)
):
    """Renew patron membership"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Create OUT parameter for new expiry date
                new_expiry_date = cursor.var(oracledb.Date)

                cursor.callproc("sp_renew_membership", [
                    request.patron_id,
                    new_expiry_date
                ])

                expiry_date = new_expiry_date.getvalue()

                return RenewMembershipResponse(
                    success=True,
                    message="Membership renewed successfully",
                    new_expiry_date=expiry_date.strftime("%Y-%m-%d") if expiry_date else None,
                    patron_id=request.patron_id
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return RenewMembershipResponse(
                    success=False,
                    message="Error renewing membership",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/suspend", response_model=SuspendPatronResponse)
async def suspend_patron(
        request: SuspendPatronRequest,
        auth: dict = Depends(require_authentication)
):
    """Suspend a patron account"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_suspend_patron", [
                    request.patron_id,
                    request.reason,
                    request.staff_id
                ])

                return SuspendPatronResponse(
                    success=True,
                    message="Patron suspended successfully",
                    patron_id=request.patron_id,
                    status="Suspended"
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return SuspendPatronResponse(
                    success=False,
                    message="Error suspending patron",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/reactivate", response_model=ReactivatePatronResponse)
async def reactivate_patron(
        request: ReactivatePatronRequest,
        auth: dict = Depends(require_authentication)
):
    """Reactivate a patron account"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_reactivate_patron", [
                    request.patron_id,
                    request.staff_id
                ])

                return ReactivatePatronResponse(
                    success=True,
                    message="Patron reactivated successfully",
                    patron_id=request.patron_id,
                    status="Active"
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return ReactivatePatronResponse(
                    success=False,
                    message="Error reactivating patron",
                    **error_response
                )

    except HTTPException:
        raise

@router.get("/statistics")
async def get_patron_statistics(
    auth: dict = Depends(require_authentication)
):
    """
    Get comprehensive patron statistics including overview, active loans,
    history, reservations, fines, and recommendations
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]
    patron_id = auth["patron_id"]  # Assuming patron_id comes from auth

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            with conn.cursor() as cursor:
                # Create output cursors
                overview_cursor = conn.cursor()
                active_loans_cursor = conn.cursor()
                loan_history_cursor = conn.cursor()
                reservations_cursor = conn.cursor()
                fines_cursor = conn.cursor()
                recommended_cursor = conn.cursor()

                try:
                    # Call the stored procedure with all 6 OUT cursors
                    cursor.callproc('sp_get_patron_statistics', [
                        patron_id,
                        overview_cursor,
                        active_loans_cursor,
                        loan_history_cursor,
                        reservations_cursor,
                        fines_cursor,
                        recommended_cursor
                    ])

                    # Helper function to convert cursor to list of dicts
                    def cursor_to_list(ref_cursor):
                        if not ref_cursor.description:
                            return []
                        columns = [col[0].lower() for col in ref_cursor.description]
                        results = []
                        for row in ref_cursor:
                            results.append(dict(zip(columns, row)))
                        return results

                    # Extract all results
                    overview = cursor_to_list(overview_cursor)
                    active_loans = cursor_to_list(active_loans_cursor)
                    loan_history = cursor_to_list(loan_history_cursor)
                    reservations = cursor_to_list(reservations_cursor)
                    fines = cursor_to_list(fines_cursor)
                    recommended = cursor_to_list(recommended_cursor)

                    return {
                        "overview": overview[0] if overview else None,
                        "active_loans": active_loans,
                        "loan_history": loan_history,
                        "reservations": reservations,
                        "fines": fines,
                        "recommended": recommended
                    }
                finally:
                    # Close all cursors
                    overview_cursor.close()
                    active_loans_cursor.close()
                    loan_history_cursor.close()
                    reservations_cursor.close()
                    fines_cursor.close()
                    recommended_cursor.close()

    except oracledb.DatabaseError as e:
        error_obj, = e.args
        if error_obj.code == 20001:
            raise HTTPException(status_code=404, detail="Patron not found")
        elif error_obj.code == 20002:
            raise HTTPException(
                status_code=500,
                detail=f"Error retrieving statistics: {error_obj.message}"
            )
        return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")



@router.get("/statistics/overview")
async def get_patron_overview(
    auth: dict = Depends(require_authentication)
):
    """Get only the overview section (lighter endpoint)"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]
    patron_id = auth["patron_id"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            overview_cursor = cursor.var(oracledb.CURSOR)
            # Pass None for cursors we don't need
            cursor.callproc('sp_get_patron_statistics', [
                patron_id,
                overview_cursor,
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR)
            ])

            cursor_obj = overview_cursor.getvalue()
            columns = [col[0].lower() for col in cursor_obj.description]
            row = cursor_obj.fetchone()
            cursor_obj.close()

            if not row:
                raise HTTPException(status_code=404, detail="Patron not found")

            return dict(zip(columns, row))

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise


@router.get("/statistics/active-loans")
async def get_active_loans(
    auth: dict = Depends(require_authentication)
):
    """Get only active loans"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]
    patron_id = auth["patron_id"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            active_loans_cursor = cursor.var(oracledb.CURSOR)
            cursor.callproc('sp_get_patron_statistics', [
                patron_id,
                cursor.var(oracledb.CURSOR),
                active_loans_cursor,
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR)
            ])

            cursor_obj = active_loans_cursor.getvalue()
            columns = [col[0].lower() for col in cursor_obj.description]
            results = []
            for row in cursor_obj:
                results.append(dict(zip(columns, row)))
            cursor_obj.close()

            return results

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise


@router.get("/statistics/reservations")
async def get_reservations(
    auth: dict = Depends(require_authentication)
):
    """Get patron's active reservations"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]
    patron_id = auth["patron_id"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            reservations_cursor = cursor.var(oracledb.CURSOR)
            cursor.callproc('sp_get_patron_statistics', [
                patron_id,
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                reservations_cursor,
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR)
            ])

            cursor_obj = reservations_cursor.getvalue()
            columns = [col[0].lower() for col in cursor_obj.description]
            results = []
            for row in cursor_obj:
                results.append(dict(zip(columns, row)))
            cursor_obj.close()

            return results

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise


@router.get("/statistics/fines")
async def get_fines(
    auth: dict = Depends(require_authentication)
):
    """Get patron's fines"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]
    patron_id = auth["patron_id"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            fines_cursor = cursor.var(oracledb.CURSOR)
            cursor.callproc('sp_get_patron_statistics', [
                patron_id,
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                cursor.var(oracledb.CURSOR),
                fines_cursor,
                cursor.var(oracledb.CURSOR)
            ])

            cursor_obj = fines_cursor.getvalue()
            columns = [col[0].lower() for col in cursor_obj.description]
            results = []
            for row in cursor_obj:
                results.append(dict(zip(columns, row)))
            cursor_obj.close()

            return results

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise