from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
import oracledb
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse
from pydantic import BaseModel

router = APIRouter(prefix="/circulation", tags=["Circulation Procedures"])


# Request/Response Models
class DeclareItemLostRequest(BaseModel):
    loan_id: int
    staff_id: int
    replacement_cost: float


class DeclareItemLostResponse(BaseResponse):
    loan_id: Optional[int] = None
    fine_id: Optional[int] = None
    replacement_cost: Optional[float] = None


# Endpoints
@router.post("/declare-item-lost", response_model=DeclareItemLostResponse)
async def declare_item_lost(
        request: DeclareItemLostRequest,
        auth: dict = Depends(require_authentication)
):
    """Declare an item as lost"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_declare_item_lost", [
                    request.loan_id,
                    request.staff_id,
                    request.replacement_cost
                ])

                return DeclareItemLostResponse(
                    success=True,
                    message="Item declared as lost",
                    loan_id=request.loan_id,
                    replacement_cost=request.replacement_cost
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return DeclareItemLostResponse(
                    success=False,
                    message="Error declaring item as lost",
                    **error_response
                )

    except HTTPException:
        raise