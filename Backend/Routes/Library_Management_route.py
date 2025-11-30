# routes/library.py
import re
import time
import logging.config
from fastapi import APIRouter, Depends, HTTPException
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
                return handle_oracle_error(e, oracle_user)

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
    Uses ROLE-BASED connection
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
                return handle_oracle_error(e, oracle_user)

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
    """
    # Debug logging - START
    logger.debug("🔍 [STATS_DEBUG] ===== PATRON STATISTICS ENDPOINT START =====")
    logger.debug(f"🔍 [STATS_DEBUG] Patron ID: {patron_id}")
    logger.debug(f"🔍 [STATS_DEBUG] Auth keys present: {list(auth.keys()) if auth else 'No auth'}")
    logger.debug(f"🔍 [STATS_DEBUG] Oracle username from auth: {auth.get('oracle_username', 'NOT_FOUND')}")
    logger.debug(
        f"🔍 [STATS_DEBUG] Oracle password length: {len(auth.get('oracle_password', '')) if auth.get('oracle_password') else 0}")

    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        # Debug connection attempt
        logger.debug(f"🔍 [STATS_DEBUG] Attempting role-based connection for user: {oracle_user}")
        logger.debug(
            f"🔍 [STATS_DEBUG] Connection pool stats before: {get_connection_pool_stats()}")  # If you have this function

        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            logger.debug("🔍 [STATS_DEBUG] ✅ Database connection established successfully")
            logger.debug(f"🔍 [STATS_DEBUG] Connection version: {conn.version}")
            logger.debug(f"🔍 [STATS_DEBUG] Connection username: {conn.username}")

            cursor = conn.cursor()
            logger.debug("🔍 [STATS_DEBUG] ✅ Database cursor created")

            try:
                # Debug function call
                logger.debug(f"🔍 [STATS_DEBUG] 📞 Calling Oracle function: fn_get_patron_statistics")
                logger.debug(f"🔍 [STATS_DEBUG] Function parameters: patron_id={patron_id}")

                # Test basic query first to verify user permissions
                try:
                    test_query = "SELECT SYSDATE FROM DUAL"
                    cursor.execute(test_query)
                    test_result = cursor.fetchone()
                    logger.debug(f"🔍 [STATS_DEBUG] ✅ Basic query test passed: {test_result[0]}")
                except Exception as test_error:
                    logger.error(f"🔍 [STATS_DEBUG] ❌ Basic query test failed: {str(test_error)}")
                    raise

                # Check if function exists and user has permissions
                try:
                    function_check = """
                    SELECT COUNT(*) 
                    FROM user_procedures 
                    WHERE object_name = 'FN_GET_PATRON_STATISTICS' 
                    OR object_name = 'PROJET_ADMIN.FN_GET_PATRON_STATISTICS'
                    """
                    cursor.execute(function_check)
                    function_exists = cursor.fetchone()[0]
                    logger.debug(f"🔍 [STATS_DEBUG] Function exists check: {function_exists}")
                except Exception as check_error:
                    logger.warning(f"🔍 [STATS_DEBUG] Function existence check failed: {str(check_error)}")

                # Call the Oracle function
                start_time = time.time()
                stats_text = cursor.callfunc(
                    "fn_get_patron_statistics",
                    str,
                    [patron_id]
                )
                call_duration = time.time() - start_time

                logger.debug(f"🔍 [STATS_DEBUG] ✅ Oracle function call completed in {call_duration:.3f}s")
                logger.debug(f"🔍 [STATS_DEBUG] Raw statistics text: '{stats_text}'")
                logger.debug(f"🔍 [STATS_DEBUG] Stats text type: {type(stats_text)}")
                logger.debug(f"🔍 [STATS_DEBUG] Stats text length: {len(stats_text) if stats_text else 0}")

                # Check for error messages from function
                if stats_text == "Patron not found":
                    logger.warning(f"🔍 [STATS_DEBUG] ❌ Patron not found in database: {patron_id}")
                    raise HTTPException(
                        status_code=404,
                        detail=f"Patron with ID {patron_id} not found"
                    )

                if stats_text == "Error retrieving statistics":
                    logger.error(f"🔍 [STATS_DEBUG] ❌ Database function returned error for patron: {patron_id}")
                    raise HTTPException(
                        status_code=500,
                        detail="Error retrieving statistics from database"
                    )

                # Parse the statistics text with detailed debugging
                logger.debug(f"🔍 [STATS_DEBUG] 🔧 Starting statistics parsing...")
                active_loans = 0
                overdue_loans = 0
                total_fines = 0.0
                reservations = 0

                try:
                    # Extract Active Loans
                    active_pattern = r'Active Loans:\s*(\d+)'
                    match = re.search(active_pattern, stats_text)
                    logger.debug(f"🔍 [STATS_DEBUG] Active Loans regex pattern: '{active_pattern}'")
                    logger.debug(f"🔍 [STATS_DEBUG] Active Loans match: {match.groups() if match else 'No match'}")
                    if match:
                        active_loans = int(match.group(1))
                        logger.debug(f"🔍 [STATS_DEBUG] ✅ Active Loans parsed: {active_loans}")

                    # Extract Overdue
                    overdue_pattern = r'Overdue:\s*(\d+)'
                    match = re.search(overdue_pattern, stats_text)
                    logger.debug(f"🔍 [STATS_DEBUG] Overdue regex pattern: '{overdue_pattern}'")
                    logger.debug(f"🔍 [STATS_DEBUG] Overdue match: {match.groups() if match else 'No match'}")
                    if match:
                        overdue_loans = int(match.group(1))
                        logger.debug(f"🔍 [STATS_DEBUG] ✅ Overdue Loans parsed: {overdue_loans}")

                    # Extract Fines (handle decimal numbers)
                    fines_pattern = r'Fines:\s*([\d.]+)'
                    match = re.search(fines_pattern, stats_text)
                    logger.debug(f"🔍 [STATS_DEBUG] Fines regex pattern: '{fines_pattern}'")
                    logger.debug(f"🔍 [STATS_DEBUG] Fines match: {match.groups() if match else 'No match'}")
                    if match:
                        total_fines = float(match.group(1))
                        logger.debug(f"🔍 [STATS_DEBUG] ✅ Fines parsed: {total_fines}")

                    # Extract Reservations
                    reservations_pattern = r'Reservations:\s*(\d+)'
                    match = re.search(reservations_pattern, stats_text)
                    logger.debug(f"🔍 [STATS_DEBUG] Reservations regex pattern: '{reservations_pattern}'")
                    logger.debug(f"🔍 [STATS_DEBUG] Reservations match: {match.groups() if match else 'No match'}")
                    if match:
                        reservations = int(match.group(1))
                        logger.debug(f"🔍 [STATS_DEBUG] ✅ Reservations parsed: {reservations}")

                    logger.debug(f"🔍 [STATS_DEBUG] ✅ All parsing completed successfully")
                    logger.debug(
                        f"🔍 [STATS_DEBUG] Parsed values - Active: {active_loans}, Overdue: {overdue_loans}, Fines: {total_fines}, Reservations: {reservations}")

                except (ValueError, AttributeError) as parse_error:
                    logger.error(f"🔍 [STATS_DEBUG] ❌ Parsing error: {parse_error}")
                    logger.error(f"🔍 [STATS_DEBUG] ❌ Stats text that failed parsing: '{stats_text}'")
                    # Continue with default values if parsing fails

                # Build response
                response = PatronStatisticsResponse(
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

                logger.debug(f"🔍 [STATS_DEBUG] ✅ Response built successfully")
                logger.debug(f"🔍 [STATS_DEBUG] ===== PATRON STATISTICS ENDPOINT END - SUCCESS =====")

                return response

            except oracledb.DatabaseError as e:
                logger.error(f"🔍 [STATS_DEBUG] ❌ Oracle DatabaseError in function call")
                logger.error(f"🔍 [STATS_DEBUG] ❌ Error code: {e.code}")
                logger.error(f"🔍 [STATS_DEBUG] ❌ Error message: {e.message}")
                logger.error(f"🔍 [STATS_DEBUG] ❌ Full error: {str(e)}")
                return handle_oracle_error(e, oracle_user)

    except HTTPException as http_exc:
        logger.debug(f"🔍 [STATS_DEBUG] ❌ HTTPException raised: {http_exc.status_code} - {http_exc.detail}")
        raise
    except oracledb.DatabaseError as db_error:
        logger.error(f"🔍 [STATS_DEBUG] ❌ Oracle DatabaseError in connection")
        logger.error(f"🔍 [STATS_DEBUG] ❌ Error code: {getattr(db_error, 'code', 'Unknown')}")
        logger.error(f"🔍 [STATS_DEBUG] ❌ Error message: {getattr(db_error, 'message', str(db_error))}")
        logger.error(f"🔍 [STATS_DEBUG] ❌ Full traceback:", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Database connection error: {str(db_error)}"
        )
    except Exception as e:
        logger.error(f"🔍 [STATS_DEBUG] ❌ Unexpected error in patron statistics endpoint")
        logger.error(f"🔍 [STATS_DEBUG] ❌ Error type: {type(e).__name__}")
        logger.error(f"🔍 [STATS_DEBUG] ❌ Error message: {str(e)}")
        logger.error(f"🔍 [STATS_DEBUG] ❌ Full traceback:", exc_info=True)
        logger.debug(f"🔍 [STATS_DEBUG] ===== PATRON STATISTICS ENDPOINT END - ERROR =====")
        raise HTTPException(
            status_code=500,
            detail=f"Unexpected error: {str(e)}"
        )