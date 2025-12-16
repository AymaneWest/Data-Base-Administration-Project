from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
import oracledb
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse
from pydantic import BaseModel, Field

router = APIRouter(prefix="/batch", tags=["Batch Operations"])


# Request/Response Models
class ProcessOverdueRequest(BaseModel):
    pass


class ProcessOverdueResponse(BaseResponse):
    notifications_processed: int = 0


class ExpireMembershipsRequest(BaseModel):
    pass


class ExpireMembershipsResponse(BaseResponse):
    memberships_expired: int = 0


class CleanupReservationsRequest(BaseModel):
    pass


class CleanupReservationsResponse(BaseResponse):
    reservations_cleaned: int = 0


class DailyReportRequest(BaseModel):
    branch_id: Optional[int] = None


class DailyReportResponse(BaseResponse):
    report_data: dict = Field(default_factory=dict)
    branch_id: Optional[int] = None


# Endpoints
@router.post("/process-overdue", response_model=ProcessOverdueResponse)
async def process_overdue_notifications(
        request: ProcessOverdueRequest,
        auth: dict = Depends(require_authentication)
):
    """Process overdue notifications"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_process_overdue_notifications", [])

                # Note: The procedure uses DBMS_OUTPUT, which we can't easily capture
                # In production, you might want to modify the procedure to return a count

                return ProcessOverdueResponse(
                    success=True,
                    message="Overdue notifications processed",
                    notifications_processed=0  # Would need to get actual count
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return ProcessOverdueResponse(
                    success=False,
                    message="Error processing overdue notifications",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/expire-memberships", response_model=ExpireMembershipsResponse)
async def expire_memberships(
        request: ExpireMembershipsRequest,
        auth: dict = Depends(require_authentication)
):
    """Expire memberships"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_expire_memberships", [])

                # Get the row count
                expired_count = cursor.rowcount

                return ExpireMembershipsResponse(
                    success=True,
                    message="Memberships expired",
                    memberships_expired=expired_count
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return ExpireMembershipsResponse(
                    success=False,
                    message="Error expiring memberships",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/cleanup-reservations", response_model=CleanupReservationsResponse)
async def cleanup_expired_reservations(
        request: CleanupReservationsRequest,
        auth: dict = Depends(require_authentication)
):
    """Cleanup expired reservations"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_cleanup_expired_reservations", [])

                # Get the row count
                cleaned_count = cursor.rowcount

                return CleanupReservationsResponse(
                    success=True,
                    message="Expired reservations cleaned",
                    reservations_cleaned=cleaned_count
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return CleanupReservationsResponse(
                    success=False,
                    message="Error cleaning up reservations",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/daily-report", response_model=DailyReportResponse)
async def generate_daily_report(
        request: DailyReportRequest,
        auth: dict = Depends(require_authentication)
):
    """Generate daily report"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_generate_daily_report", [
                    request.branch_id
                ])

                # Note: The procedure uses DBMS_OUTPUT
                # In production, modify the procedure to return structured data

                report_data = {
                    "checkouts": 0,
                    "returns": 0,
                    "new_patrons": 0,
                    "overdue": 0,
                    "total_fines": 0
                }

                return DailyReportResponse(
                    success=True,
                    message="Daily report generated",
                    report_data=report_data,
                    branch_id=request.branch_id
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return DailyReportResponse(
                    success=False,
                    message="Error generating daily report",
                    **error_response
                )

    except HTTPException:
        raise