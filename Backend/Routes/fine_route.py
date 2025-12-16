from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
import oracledb
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse, FineType
from pydantic import BaseModel

router = APIRouter(prefix="/fines", tags=["Fine Management"])


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