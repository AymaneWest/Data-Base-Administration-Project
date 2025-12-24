# routes/library.py
import re
from typing import List, Optional
import time
import logging.config
from fastapi import APIRouter, Depends, HTTPException, Query
from database.connection import get_role_based_connection, handle_oracle_error
from dependencies.auth import require_authentication
import oracledb
import logging
from Schemas.Patron_schema import AddPatronRequest, AddPatronResponse, UpdatePatronRequest, RenewMembershipRequest, RenewMembershipResponse
from Schemas.Reporting_schemas import PatronStatisticsRequest, PatronStatisticsResponse
from Schemas.Base_Schema import StatusResponse
from Schemas.Material_schemas import AddMaterialRequest, AddMaterialResponse, AddCopyRequest, AddCopyResponse
from Schemas.Reservation_schemas import PlaceReservationRequest, PlaceReservationResponse
from Schemas.Fines_schemas import PayFineRequest, PayFineResponse
from Schemas.Circulation_schemas import CheckoutItemRequest, CheckoutItemResponse, CheckinItemRequest, CheckinItemResponse, RenewLoanRequest, RenewLoanResponse
from Schemas.statistics import (
    DashboardStats, PatronDetailsResponse, PatronInfo, PatronLoan,
    PatronFine, PatronReservation, ExpiringLoan, FineReport,
    PopularMaterial, BranchPerformance, ExpiringReservation,
    DailyActivity, MembershipStat, AtRiskPatron, MonthlyStat,
    AlertLevel, RiskCategory
)

# In your logging setup
logging_config = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'detailed': {
            'format': '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        },
        'debug': {
            'format': '%(asctime)s - %(name)s - %(levelname)s - [%(filename)s:%(lineno)d] - %(message)s'
        }
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'debug',
            'level': 'DEBUG'
        },
        'file': {
            'class': 'logging.FileHandler',
            'filename': 'debug.log',
            'formatter': 'detailed',
            'level': 'DEBUG'
        }
    },
    'loggers': {
        'your_app_name': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
            'propagate': False
        }
    }
}
logging.config.dictConfig(logging_config)
logger = logging.getLogger(__name__)

# ⭐ ALL endpoints automatically protected via router dependencies
router = APIRouter(
    prefix="/library",
    tags=["library"],
    dependencies=[Depends(require_authentication)]
)


# Patron Management Routes
@router.post("/patrons", response_model=AddPatronResponse)
async def add_patron(
        request: AddPatronRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Add patron - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection (user's Oracle user based on their role)
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                new_patron_id = cursor.var(int)

                cursor.callproc("sp_add_patron", [
                    request.card_number,
                    request.first_name,
                    request.last_name,
                    request.email,
                    request.phone,
                    request.address,
                    request.date_of_birth,
                    request.membership_type.value,
                    request.branch_id,
                    new_patron_id
                ])

                return AddPatronResponse(
                    success=True,
                    message="Patron created successfully",
                    patron_id=new_patron_id.getvalue(),
                    membership_expiry=None,  # You might need to fetch this separately
                    max_borrow_limit=10  # You might need to fetch this separately
                )

            except oracledb.DatabaseError as e:
                error_obj, = e.args
                error_message = str(error_obj.message) if hasattr(error_obj, 'message') else str(e)
                
                # Extract user-friendly message from Oracle error
                if error_obj.code == 20101:
                    message = "Card number or email already exists"
                elif error_obj.code == 20102:
                    message = "Invalid branch ID"
                else:
                    message = error_message
                
                return AddPatronResponse(
                    success=False,
                    message=message,
                    patron_id=None,
                    membership_expiry=None,
                    max_borrow_limit=None
                )

    except HTTPException:
        raise


@router.put("/patrons/{patron_id}", response_model=StatusResponse)
async def update_patron(
        patron_id: int,
        request: UpdatePatronRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Update patron - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_update_patron", [
                    patron_id,
                    request.email,
                    request.phone,
                    request.address
                ])

                return StatusResponse(
                    success=True,
                    message="Patron updated successfully"
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


# Circulation Routes
@router.post("/checkout", response_model=CheckoutItemResponse)
async def checkout_item(
        request: CheckoutItemRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Checkout item - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                loan_id = cursor.var(int)

                cursor.callproc("sp_checkout_item", [
                    request.patron_id,
                    request.copy_id,
                    request.staff_id,
                    loan_id
                ])

                return CheckoutItemResponse(
                    success=True,
                    message="Item checked out successfully",
                    loan_id=loan_id.getvalue(),
                    due_date=None  # You might need to fetch this separately
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


@router.post("/checkin", response_model=CheckinItemResponse)
async def checkin_item(
        request: CheckinItemRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Checkin item - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                fine_assessed = cursor.var(float)

                cursor.callproc("sp_checkin_item", [
                    request.loan_id,
                    request.staff_id,
                    fine_assessed
                ])

                return CheckinItemResponse(
                    success=True,
                    message="Item checked in successfully",
                    fine_assessed=fine_assessed.getvalue(),
                    days_overdue=0  # You might need to calculate this
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


@router.post("/renew-loan", response_model=RenewLoanResponse)
async def renew_loan(
        request: RenewLoanRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Renew loan - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                new_due_date = cursor.var(oracledb.DATETIME)

                cursor.callproc("sp_renew_loan", [
                    request.loan_id,
                    new_due_date
                ])

                return RenewLoanResponse(
                    success=True,
                    message="Loan renewed successfully",
                    new_due_date=new_due_date.getvalue(),
                    renewal_count=0  # You might need to fetch this
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


# Material Management Routes
@router.post("/materials", response_model=AddMaterialResponse)
async def add_material(
        request: AddMaterialRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Add material - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection (user's Oracle user based on their role)
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                new_material_id = cursor.var(int)

                cursor.callproc("sp_add_material", [
                    request.title,
                    request.subtitle,
                    request.material_type.value,
                    request.isbn,
                    request.publication_year,
                    request.publisher_id,
                    request.language,
                    request.pages,
                    request.description,
                    request.total_copies,
                    new_material_id
                ])

                return AddMaterialResponse(
                    success=True,
                    message="Material added successfully",
                    material_id=new_material_id.getvalue()
                )

            except oracledb.DatabaseError as e:
                error_obj, = e.args
                error_message = str(error_obj.message) if hasattr(error_obj, 'message') else str(e)
                
                # Extract user-friendly message from Oracle error
                if error_obj.code == 20301:
                    message = "Invalid publisher ID"
                elif error_obj.code == 20302:
                    message = "ISBN already exists"
                elif error_obj.code == 20303:
                    message = "Material creation failed"
                else:
                    message = error_message
                
                return AddMaterialResponse(
                    success=False,
                    message=message,
                    material_id=None
                )

    except HTTPException:
        raise


# Fine Management Routes
@router.post("/fines/pay", response_model=PayFineResponse)
async def pay_fine(
        request: PayFineRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Pay fine - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_pay_fine", [
                    request.fine_id,
                    float(request.payment_amount),
                    request.payment_method.value,
                    request.staff_id
                ])

                return PayFineResponse(
                    success=True,
                    message="Fine payment processed successfully",
                    remaining_balance=0,  # You might need to fetch this
                    new_fine_status="Paid"  # You might need to fetch this
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise

def get_connection_pool_stats():
    """Get connection pool statistics for debugging"""
    try:
        # If you're using connection pooling, add stats here
        return "Pool stats not implemented"
    except Exception as e:
        return f"Error getting pool stats: {str(e)}"

def debug_auth_middleware():
    """Add this to your authentication middleware"""
    logger.debug(f"🔐 [AUTH_DEBUG] Authentication process started")
    # Add detailed auth debugging here
# Reporting Routes
@router.get("/patrons/{patron_id}/statistics", response_model=PatronStatisticsResponse)
async def get_patron_statistics(
        patron_id: int,
        auth: dict = Depends(require_authentication)
):
    """
    Get patron statistics - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection

    Returns parsed statistics from fn_get_patron_statistics function.
    The function returns a string like:
    "Active Loans: 3, Overdue: 1, Fines: 25.50 DH, Reservations: 2"
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Call the Oracle function
                stats_text = cursor.callfunc(
                    "fn_get_patron_statistics",  # Or: "PROJET_ADMIN.fn_get_patron_statistics"
                    str,
                    [patron_id]
                )

                logger.info(f"Statistics for patron {patron_id}: {stats_text}")

                # Check for error messages from function
                if stats_text == "Patron not found":
                    raise HTTPException(
                        status_code=404,
                        detail=f"Patron with ID {patron_id} not found"
                    )

                if stats_text == "Error retrieving statistics":
                    raise HTTPException(
                        status_code=500,
                        detail="Error retrieving statistics from database"
                    )

                # Parse the statistics text
                # Expected format: "Active Loans: 3, Overdue: 1, Fines: 25.50 DH, Reservations: 2"
                active_loans = 0
                overdue_loans = 0
                total_fines = 0.0
                reservations = 0

                try:
                    # Extract Active Loans
                    match = re.search(r'Active Loans:\s*(\d+)', stats_text)
                    if match:
                        active_loans = int(match.group(1))

                    # Extract Overdue
                    match = re.search(r'Overdue:\s*(\d+)', stats_text)
                    if match:
                        overdue_loans = int(match.group(1))

                    # Extract Fines (handle decimal numbers)
                    match = re.search(r'Fines:\s*([\d.]+)', stats_text)
                    if match:
                        total_fines = float(match.group(1))

                    # Extract Reservations
                    match = re.search(r'Reservations:\s*(\d+)', stats_text)
                    if match:
                        reservations = int(match.group(1))

                except (ValueError, AttributeError) as parse_error:
                    logger.error(f"Error parsing statistics: {parse_error}")
                    # Continue with default values if parsing fails

                return PatronStatisticsResponse(
                    success=True,
                    message="Statistics retrieved successfully",
                    patron_id=patron_id,
                    statistics_text=stats_text,
                    active_loans=active_loans,
                    overdue_loans=overdue_loans,
                    total_fines=total_fines,
                    reservations=reservations,
                    executed_by_oracle_user=oracle_user
                )

            except oracledb.DatabaseError as e:
                # This catches Oracle errors like ORA-00942 (table doesn't exist)
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Unexpected error: {str(e)}"
        )

@router.get("/user-info")
async def get_user_info(auth: dict = Depends(require_authentication)):
    """
    Get authenticated user information
    """
    return {
        "user_id": auth["user_id"],
        "username": auth["username"],
        "oracle_username": auth["oracle_username"],
        "roles": auth["roles"],
        "session_status": auth["session_status"]
    }

@router.get("/branches")
async def get_branches(auth: dict = Depends(require_authentication)):
    """
    Get all library branches
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    SELECT 
                        branch_id,
                        branch_name,
                        address,
                        phone,
                        email,
                        opening_hours,
                        branch_capacity,
                        library_id
                    FROM branches
                    ORDER BY branch_name
                """)
                
                columns = [col[0].lower() for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                return results

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise