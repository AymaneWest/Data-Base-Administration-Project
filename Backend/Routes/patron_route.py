from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
import oracledb
from datetime import date
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse
from pydantic import BaseModel

router = APIRouter(prefix="/patrons", tags=["Patron Management"])


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