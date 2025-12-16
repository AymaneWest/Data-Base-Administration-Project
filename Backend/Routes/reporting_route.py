from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
import oracledb
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse
from pydantic import BaseModel

router = APIRouter(prefix="/reports", tags=["Reporting Functions"])


# Request/Response Models
class OverdueCountRequest(BaseModel):
    branch_id: Optional[int] = None


class OverdueCountResponse(BaseResponse):
    overdue_count: int = 0
    branch_id: Optional[int] = None


class TotalFinesRequest(BaseModel):
    patron_id: Optional[int] = None


class TotalFinesResponse(BaseResponse):
    total_fines: float = 0.0
    patron_id: Optional[int] = None


class MaterialAvailabilityRequest(BaseModel):
    material_id: int


class MaterialAvailabilityResponse(BaseResponse):
    availability_status: str = ""
    total_copies: Optional[int] = None
    available_copies: Optional[int] = None


# Endpoints
@router.post("/overdue-count", response_model=OverdueCountResponse)
async def get_overdue_count(
        request: OverdueCountRequest,
        auth: dict = Depends(require_authentication)
):
    """Get count of overdue items"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                result = cursor.callfunc(
                    "fn_get_overdue_count",
                    int,
                    [request.branch_id]
                )

                return OverdueCountResponse(
                    success=True,
                    message="Overdue count retrieved",
                    overdue_count=result,
                    branch_id=request.branch_id
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return OverdueCountResponse(
                    success=False,
                    message="Error getting overdue count",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/total-fines", response_model=TotalFinesResponse)
async def calculate_total_fines(
        request: TotalFinesRequest,
        auth: dict = Depends(require_authentication)
):
    """Calculate total fines"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                result = cursor.callfunc(
                    "fn_calculate_total_fines",
                    float,
                    [request.patron_id]
                )

                return TotalFinesResponse(
                    success=True,
                    message="Total fines calculated",
                    total_fines=result,
                    patron_id=request.patron_id
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return TotalFinesResponse(
                    success=False,
                    message="Error calculating total fines",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/material-availability", response_model=MaterialAvailabilityResponse)
async def check_material_availability(
        request: MaterialAvailabilityRequest,
        auth: dict = Depends(require_authentication)
):
    """Check material availability"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                result = cursor.callfunc(
                    "fn_check_material_availability",
                    str,
                    [request.material_id]
                )

                # Parse the result to get counts if available
                total_copies = None
                available_copies = None

                # Try to extract numbers from result string
                import re
                match = re.search(r'\((\d+)/(\d+)', result)
                if match:
                    available_copies = int(match.group(1))
                    total_copies = int(match.group(2))

                return MaterialAvailabilityResponse(
                    success=True,
                    message="Availability checked",
                    availability_status=result,
                    total_copies=total_copies,
                    available_copies=available_copies
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return MaterialAvailabilityResponse(
                    success=False,
                    message="Error checking availability",
                    **error_response
                )

    except HTTPException:
        raise