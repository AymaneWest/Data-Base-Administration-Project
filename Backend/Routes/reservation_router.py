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
@router.get("/active")
async def get_active_reservations(
    status: Optional[str] = None,
    auth: dict = Depends(require_authentication)
):
    """
    Get all active reservations with optional status filter
    Status can be: Pending, Ready, Expired, or None for all
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                query = """
                    SELECT 
                        r.reservation_id,
                        r.material_id,
                        m.title AS material_title,
                        m.material_type,
                        r.patron_id,
                        p.first_name || ' ' || p.last_name AS patron_name,
                        p.email AS patron_email,
                        p.phone AS patron_phone,
                        r.reservation_status,
                        TO_CHAR(r.reservation_date, 'YYYY-MM-DD HH24:MI:SS') AS reservation_date,
                        TO_CHAR(r.pickup_deadline, 'YYYY-MM-DD') AS pickup_deadline,
                        r.queue_position,
                        b.branch_name
                    FROM RESERVATIONS r
                    JOIN MATERIALS m ON r.material_id = m.material_id
                    JOIN PATRONS p ON r.patron_id = p.patron_id
                    LEFT JOIN BRANCHES b ON p.registered_branch_id = b.branch_id
                    WHERE 1=1
                """
                
                params = {}
                
                if status:
                    query += " AND UPPER(r.reservation_status) = UPPER(:status)"
                    params["status"] = status
                else:
                    # Only show active statuses by default
                    query += " AND r.reservation_status IN ('Pending', 'Ready', 'Expired')"
                
                query += " ORDER BY r.reservation_date DESC"
                
                cursor.execute(query, params)
                
                columns = [col[0].lower() for col in cursor.description]
                results = []
                for row in cursor.fetchall():
                    results.append(dict(zip(columns, row)))
                
                return {
                    "success": True,
                    "count": len(results),
                    "reservations": results
                }

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return {
                    "success": False,
                    "message": "Error fetching reservations",
                    "count": 0,
                    "reservations": [],
                    **error_response
                }

    except HTTPException:
        raise



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
                error_obj, = e.args
                return PlaceReservationResponse(
                    success=False,
                    message=str(error_obj.message) if hasattr(error_obj, 'message') else "Error placing reservation"
                )
    except HTTPException:
        raise
    except Exception as e:
        return PlaceReservationResponse(
            success=False,
            message=f"Unexpected error: {str(e)}"
        )


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