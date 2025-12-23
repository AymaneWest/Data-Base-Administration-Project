from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
import oracledb
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse
from pydantic import BaseModel

router = APIRouter(prefix="/reservations", tags=["Reservation Procedures"])


# Request/Response Models
class PlaceReservationRequest(BaseModel):
    material_id: int
    patron_id: int


class PlaceReservationResponse(BaseResponse):
    reservation_id: Optional[int] = None
    queue_position: Optional[int] = None


class CancelReservationRequest(BaseModel):
    reservation_id: int
    patron_id: int


class CancelReservationResponse(BaseResponse):
    reservation_id: Optional[int] = None


class FulfillReservationRequest(BaseModel):
    reservation_id: int
    copy_id: int
    staff_id: int


class FulfillReservationResponse(BaseResponse):
    reservation_id: Optional[int] = None
    pickup_deadline: Optional[str] = None


# Endpoints
@router.post("/place", response_model=PlaceReservationResponse)
async def place_reservation(
        request: PlaceReservationRequest,
        auth: dict = Depends(require_authentication)
):
    """Place a reservation for a material"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Create OUT parameter for reservation ID
                reservation_id = cursor.var(int)

                cursor.callproc("sp_place_reservation", [
                    request.material_id,
                    request.patron_id,
                    reservation_id
                ])

                return PlaceReservationResponse(
                    success=True,
                    message="Reservation placed successfully",
                    reservation_id=reservation_id.getvalue()
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return PlaceReservationResponse(
                    success=False,
                    message="Error placing reservation",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/cancel", response_model=CancelReservationResponse)
async def cancel_reservation(
        request: CancelReservationRequest,
        auth: dict = Depends(require_authentication)
):
    """Cancel a reservation"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_cancel_reservation", [
                    request.reservation_id,
                    request.patron_id
                ])

                return CancelReservationResponse(
                    success=True,
                    message="Reservation cancelled successfully",
                    reservation_id=request.reservation_id
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return CancelReservationResponse(
                    success=False,
                    message="Error cancelling reservation",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/fulfill", response_model=FulfillReservationResponse)
async def fulfill_reservation(
        request: FulfillReservationRequest,
        auth: dict = Depends(require_authentication)
):
    """Fulfill a reservation"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_fulfill_reservation", [
                    request.reservation_id,
                    request.copy_id,
                    request.staff_id
                ])

                # Calculate pickup deadline (3 days from now)
                from datetime import datetime, timedelta
                pickup_deadline = (datetime.now() + timedelta(days=3)).strftime("%Y-%m-%d")

                return FulfillReservationResponse(
                    success=True,
                    message="Reservation fulfilled successfully",
                    reservation_id=request.reservation_id,
                    pickup_deadline=pickup_deadline
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return FulfillReservationResponse(
                    success=False,
                    message="Error fulfilling reservation",
                    **error_response
                )

    except HTTPException:
        raise