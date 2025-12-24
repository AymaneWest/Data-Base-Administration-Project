# Routes/statistics_route.py
from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional
import oracledb
from datetime import date, datetime
import logging

# Import schemas
from Schemas.statistics import (
    DashboardStats, PatronDetailsResponse, PatronInfo, PatronLoan,
    PatronFine, PatronReservation, ExpiringLoan, FineReport,
    PopularMaterial, BranchPerformance, ExpiringReservation,
    DailyActivity, MembershipStat, AtRiskPatron, MonthlyStat,
    AlertLevel, RiskCategory
)

# Import your authentication and connection functions
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection

# Create router
router = APIRouter(prefix="/statistics",
    tags=["statistics"])

logger = logging.getLogger(__name__)


def handle_oracle_error(e: oracledb.DatabaseError, username: str):
    """Handle Oracle database errors"""
    if hasattr(e, 'args') and e.args:
        error_obj = e.args[0]
        error_code = getattr(error_obj, 'code', 0)
        error_message = getattr(error_obj, 'message', str(e))
    else:
        error_code = 0
        error_message = str(e)

    logger.error(f"Oracle error for user {username}: {error_code} - {error_message}")

    if error_code == 1403:  # No data found
        return []
    elif error_code in (942, 1917):  # Table or view does not exist
        raise HTTPException(
            status_code=403,
            detail=f"Access denied for user {username}. Required privileges missing."
        )
    elif error_code == 20000:  # User-defined exception
        raise HTTPException(status_code=400, detail=error_message)
    else:
        raise HTTPException(
            status_code=500,
            detail=f"Database error: {error_message}"
        )


# ============================================================================
# SECTION 1: DASHBOARD ENDPOINT
# ============================================================================

@router.get("/dashboard", response_model=DashboardStats)
async def get_admin_dashboard(
        auth: dict = Depends(require_authentication)
):
    """
    Get comprehensive dashboard statistics
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            result_cursor = cursor.var(oracledb.CURSOR)

            cursor.callproc("sp_get_admin_dashboard", [
                None,  # p_branch_id
                result_cursor
            ])

            result = result_cursor.getvalue().fetchone()

            if result:
                # Get column names
                columns = [col[0].lower() for col in result_cursor.getvalue().description]
                data = dict(zip(columns, result))
                return DashboardStats(**data)
            else:
                return DashboardStats()

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_admin_dashboard: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


# ============================================================================
# SECTION 2: PATRON DETAILS ENDPOINT
# ============================================================================

@router.get("/patrons/me", response_model=PatronDetailsResponse)
async def get_my_patron_details(
        auth: dict = Depends(require_authentication)
):
    """
    Get patron details for the currently authenticated user
    Automatically finds patron_id from user_id
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]
    user_id = auth["user_id"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            with conn.cursor() as cursor:
                # First, get patron_id from user_id
                cursor.execute("""
                    SELECT patron_id 
                    FROM patrons 
                    WHERE user_id = :user_id
                """, [user_id])
                
                patron_row = cursor.fetchone()
                if not patron_row:
                    raise HTTPException(
                        status_code=404,
                        detail="No patron record found for this user"
                    )
                
                patron_id = int(patron_row[0])
                
                # Create output cursors
                info_cursor = conn.cursor()
                loans_cursor = conn.cursor()
                fines_cursor = conn.cursor()
                reservations_cursor = conn.cursor()

                try:
                    cursor.callproc("sp_get_patron_details", [
                        patron_id,
                        info_cursor,
                        loans_cursor,
                        fines_cursor,
                        reservations_cursor
                    ])

                    # Fetch patron info
                    info_columns = [col[0].lower() for col in info_cursor.description]
                    info_result = info_cursor.fetchone()
                    if not info_result:
                        raise HTTPException(status_code=404, detail=f"Patron {patron_id} not found")
                    
                    # Convert to dict and clean datetime fields
                    info_dict = dict(zip(info_columns, info_result))
                    
                    # Convert datetime to date for fields that need it
                    datetime_to_date_fields = ['registration_date', 'membership_expiry']
                    for field in datetime_to_date_fields:
                        if field in info_dict and info_dict[field] is not None:
                            if hasattr(info_dict[field], 'date'):
                                info_dict[field] = info_dict[field].date()
                    
                    patron_info = PatronInfo(**info_dict)

                    # Fetch loans
                    loans = []
                    if loans_cursor.description:
                        loans_columns = [col[0].lower() for col in loans_cursor.description]
                        for row in loans_cursor:
                            loan_dict = dict(zip(loans_columns, row))
                            # Convert datetime fields if needed
                            for field in ['checkout_date', 'due_date', 'return_date']:
                                if field in loan_dict and loan_dict[field] is not None:
                                    if hasattr(loan_dict[field], 'date'):
                                        loan_dict[field] = loan_dict[field].date()
                            loans.append(PatronLoan(**loan_dict))

                    # Fetch fines
                    fines = []
                    if fines_cursor.description:
                        fines_columns = [col[0].lower() for col in fines_cursor.description]
                        for row in fines_cursor:
                            fine_dict = dict(zip(fines_columns, row))
                            # Convert datetime fields if needed
                            for field in ['fine_date', 'payment_date']:
                                if field in fine_dict and fine_dict[field] is not None:
                                    if hasattr(fine_dict[field], 'date'):
                                        fine_dict[field] = fine_dict[field].date()
                            fines.append(PatronFine(**fine_dict))

                    # Fetch reservations
                    reservations = []
                    if reservations_cursor.description:
                        res_columns = [col[0].lower() for col in reservations_cursor.description]
                        for row in reservations_cursor:
                            res_dict = dict(zip(res_columns, row))
                            # Convert datetime fields if needed
                            for field in ['reservation_date', 'expiry_date', 'notification_date']:
                                if field in res_dict and res_dict[field] is not None:
                                    if hasattr(res_dict[field], 'date'):
                                        res_dict[field] = res_dict[field].date()
                            reservations.append(PatronReservation(**res_dict))

                    return PatronDetailsResponse(
                        patron_info=patron_info,
                        loans=loans,
                        fines=fines,
                        reservations=reservations
                    )
                finally:
                    # Close all cursors
                    info_cursor.close()
                    loans_cursor.close()
                    fines_cursor.close()
                    reservations_cursor.close()

    except HTTPException:
        raise
    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_my_patron_details: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")



@router.get("/patrons/{patron_id}/details", response_model=PatronDetailsResponse)
async def get_patron_details(
        patron_id: int,
        auth: dict = Depends(require_authentication)
):
    """
    Get detailed information about a specific patron
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            with conn.cursor() as cursor:
                # Create output cursors
                info_cursor = conn.cursor()
                loans_cursor = conn.cursor()
                fines_cursor = conn.cursor()
                reservations_cursor = conn.cursor()

                try:
                    cursor.callproc("sp_get_patron_details", [
                        patron_id,
                        info_cursor,
                        loans_cursor,
                        fines_cursor,
                        reservations_cursor
                    ])

                    # Fetch patron info
                    info_columns = [col[0].lower() for col in info_cursor.description]
                    info_result = info_cursor.fetchone()
                    if not info_result:
                        raise HTTPException(status_code=404, detail=f"Patron {patron_id} not found")
                    
                    # Convert to dict and clean datetime fields
                    info_dict = dict(zip(info_columns, info_result))
                    
                    # Convert datetime to date for fields that need it
                    datetime_to_date_fields = ['registration_date', 'membership_expiry']
                    for field in datetime_to_date_fields:
                        if field in info_dict and info_dict[field] is not None:
                            if hasattr(info_dict[field], 'date'):
                                info_dict[field] = info_dict[field].date()
                    
                    patron_info = PatronInfo(**info_dict)

                    # Fetch loans
                    loans = []
                    if loans_cursor.description:
                        loans_columns = [col[0].lower() for col in loans_cursor.description]
                        for row in loans_cursor:
                            loan_dict = dict(zip(loans_columns, row))
                            # Convert datetime fields if needed
                            for field in ['checkout_date', 'due_date', 'return_date']:
                                if field in loan_dict and loan_dict[field] is not None:
                                    if hasattr(loan_dict[field], 'date'):
                                        loan_dict[field] = loan_dict[field].date()
                            loans.append(PatronLoan(**loan_dict))

                    # Fetch fines
                    fines = []
                    if fines_cursor.description:
                        fines_columns = [col[0].lower() for col in fines_cursor.description]
                        for row in fines_cursor:
                            fine_dict = dict(zip(fines_columns, row))
                            # Convert datetime fields if needed
                            for field in ['fine_date', 'payment_date']:
                                if field in fine_dict and fine_dict[field] is not None:
                                    if hasattr(fine_dict[field], 'date'):
                                        fine_dict[field] = fine_dict[field].date()
                            fines.append(PatronFine(**fine_dict))

                    # Fetch reservations
                    reservations = []
                    if reservations_cursor.description:
                        res_columns = [col[0].lower() for col in reservations_cursor.description]
                        for row in reservations_cursor:
                            res_dict = dict(zip(res_columns, row))
                            # Convert datetime fields if needed
                            for field in ['reservation_date', 'expiry_date', 'notification_date']:
                                if field in res_dict and res_dict[field] is not None:
                                    if hasattr(res_dict[field], 'date'):
                                        res_dict[field] = res_dict[field].date()
                            reservations.append(PatronReservation(**res_dict))

                    return PatronDetailsResponse(
                        patron_info=patron_info,
                        loans=loans,
                        fines=fines,
                        reservations=reservations
                    )
                finally:
                    # Close all cursors
                    info_cursor.close()
                    loans_cursor.close()
                    fines_cursor.close()
                    reservations_cursor.close()

    except HTTPException:
        raise
    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_patron_details: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")



# ============================================================================
# SECTION 3: EXPIRING LOANS ENDPOINT
# ============================================================================

@router.get("/loans/expiring", response_model=List[ExpiringLoan])
async def get_expiring_loans(
        days_ahead: Optional[int] = Query(3, ge=1, le=30),
        branch_id: Optional[int] = Query(None),
        auth: dict = Depends(require_authentication)
):
    """
    Get loans expiring within specified days
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            with conn.cursor() as cur:
                result_cursor = conn.cursor()

                try:
                    cur.callproc("sp_get_expiring_loans", [
                        days_ahead,
                        branch_id,
                        result_cursor
                    ])

                    columns = [c[0].lower() for c in result_cursor.description]
                    results = []
                    for row in result_cursor:
                        row_dict = dict(zip(columns, row))
                        if 'alert_level' in row_dict:
                            row_dict['alert_level'] = AlertLevel(row_dict['alert_level'])
                        results.append(ExpiringLoan(**row_dict))

                    return results
                finally:
                    result_cursor.close()

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_expiring_loans: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


# ============================================================================
# SECTION 4: FINES REPORT ENDPOINT
# ============================================================================

@router.get("/fines/report", response_model=List[FineReport])
async def get_fines_report(
        status_filter: str = Query("ALL"),
        branch_id: Optional[int] = Query(None),
        date_from: Optional[date] = Query(None),
        date_to: Optional[date] = Query(None),
        auth: dict = Depends(require_authentication)
):
    """
    Get detailed fines report with filters
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    if date_to is None:
        date_to = date.today()

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            with conn.cursor() as cur:
                result_cursor = conn.cursor()

                try:
                    cur.callproc("sp_get_fines_report", [
                        status_filter,
                        branch_id,
                        date_from,
                        date_to,
                        result_cursor
                    ])

                    columns = [c[0].lower() for c in result_cursor.description]
                    results = [
                        FineReport(**dict(zip(columns, row)))
                        for row in result_cursor
                    ]

                    return results
                finally:
                    result_cursor.close()

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_fines_report: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


# ============================================================================
# SECTION 5: POPULAR MATERIALS ENDPOINT
# ============================================================================

@router.get("/materials/popular", response_model=List[PopularMaterial])
async def get_popular_materials(
        top_n: Optional[int] = Query(10, ge=1, le=100),
        material_type: Optional[str] = Query(None),
        period_days: Optional[int] = Query(30, ge=1, le=365),
        auth: dict = Depends(require_authentication)
):
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            with conn.cursor() as cur:
                result_cursor = conn.cursor()

                cur.callproc(
                    "sp_get_popular_materials",
                    [top_n, material_type, period_days, result_cursor]
                )

                columns = [c[0].lower() for c in result_cursor.description]
                results = [
                    PopularMaterial(**dict(zip(columns, row)))
                    for row in result_cursor
                ]

                result_cursor.close()
                return results

    except oracledb.DatabaseError as e:
        logger.error(f"Database error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))



# ============================================================================
# SECTION 6: BRANCH PERFORMANCE ENDPOINT
# ============================================================================

@router.get("/branches/performance", response_model=List[BranchPerformance])
async def get_branch_performance(
        date_from: Optional[date] = Query(None),
        date_to: Optional[date] = Query(None),
        auth: dict = Depends(require_authentication)
):
    """
    Get performance metrics for all branches
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    if date_from is None:
        today = date.today()
        date_from = date(today.year, today.month, 1)
    if date_to is None:
        date_to = date.today()

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            with conn.cursor() as cur:
                result_cursor = conn.cursor()

                try:
                    cur.callproc("sp_get_branch_performance", [
                        date_from,
                        date_to,
                        result_cursor
                    ])

                    columns = [c[0].lower() for c in result_cursor.description]
                    results = [
                        BranchPerformance(**dict(zip(columns, row)))
                        for row in result_cursor
                    ]

                    return results
                finally:
                    result_cursor.close()

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_branch_performance: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


# ============================================================================
# SECTION 7: EXPIRING RESERVATIONS ENDPOINT
# ============================================================================

@router.get("/reservations/expiring", response_model=List[ExpiringReservation])
async def get_expiring_reservations(
        branch_id: Optional[int] = Query(None),
        auth: dict = Depends(require_authentication)
):
    """
    Get reservations that are about to expire
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            with conn.cursor() as cur:
                result_cursor = conn.cursor()

                try:
                    cur.callproc("sp_get_expiring_reservations", [
                        branch_id,
                        result_cursor
                    ])

                    columns = [c[0].lower() for c in result_cursor.description]
                    results = [
                        ExpiringReservation(**dict(zip(columns, row)))
                        for row in result_cursor
                    ]

                    return results
                finally:
                    result_cursor.close()

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_expiring_reservations: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


# ============================================================================
# SECTION 8: DAILY ACTIVITY ENDPOINT
# ============================================================================

@router.get("/activity/daily", response_model=List[DailyActivity])
async def get_daily_activity(
        activity_date: Optional[date] = Query(None),
        branch_id: Optional[int] = Query(None),
        auth: dict = Depends(require_authentication)
):
    """
    Get daily activity statistics
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    if activity_date is None:
        activity_date = date.today()

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            with conn.cursor() as cur:
                result_cursor = conn.cursor()

                try:
                    cur.callproc("sp_get_daily_activity", [
                        activity_date,
                        branch_id,
                        result_cursor
                    ])

                    columns = [c[0].lower() for c in result_cursor.description]
                    results = [
                        DailyActivity(**dict(zip(columns, row)))
                        for row in result_cursor
                    ]

                    return results
                finally:
                    result_cursor.close()

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_daily_activity: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")



# ============================================================================
# SECTION 9: MEMBERSHIP STATS ENDPOINT
# ============================================================================

@router.get("/memberships/stats", response_model=List[MembershipStat])
async def get_membership_stats(
        auth: dict = Depends(require_authentication)
):
    """
    Get statistics by membership type
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            result_cursor = cursor.var(oracledb.CURSOR)

            cursor.callproc("sp_get_membership_stats", [result_cursor])

            results = []
            result_set = result_cursor.getvalue()
            if result_set:
                columns = [col[0].lower() for col in result_set.description]
                for row in result_set:
                    results.append(MembershipStat(**dict(zip(columns, row))))

            return results

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_membership_stats: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


# ============================================================================
# SECTION 10: AT-RISK PATRONS ENDPOINT
# ============================================================================

@router.get("/patrons/at-risk", response_model=List[AtRiskPatron])
async def get_at_risk_patrons(
        branch_id: Optional[int] = Query(None),
        auth: dict = Depends(require_authentication)
):
    """
    Get patrons with high risk scores
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            result_cursor = cursor.var(oracledb.CURSOR)

            cursor.callproc("sp_get_at_risk_patrons", [
                branch_id,
                result_cursor
            ])

            results = []
            result_set = result_cursor.getvalue()
            if result_set:
                columns = [col[0].lower() for col in result_set.description]
                for row in result_set:
                    # Convert risk_category string to Enum
                    row_dict = dict(zip(columns, row))
                    if 'risk_category' in row_dict:
                        row_dict['risk_category'] = RiskCategory(row_dict['risk_category'])
                    results.append(AtRiskPatron(**row_dict))

            return results

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_at_risk_patrons: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


# ============================================================================
# SECTION 11: MONTHLY STATS ENDPOINT
# ============================================================================

@router.get("/stats/monthly", response_model=List[MonthlyStat])
async def get_monthly_stats(
        month: Optional[int] = Query(None, ge=1, le=12),
        year: Optional[int] = Query(None, ge=1900),
        auth: dict = Depends(require_authentication)
):
    """
    Get monthly statistics
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    # Use current month/year if not specified
    if month is None:
        month = datetime.now().month
    if year is None:
        year = datetime.now().year

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            result_cursor = cursor.var(oracledb.CURSOR)

            cursor.callproc("sp_get_monthly_stats", [
                month,
                year,
                result_cursor
            ])

            results = []
            result_set = result_cursor.getvalue()
            if result_set:
                columns = [col[0].lower() for col in result_set.description]
                for row in result_set:
                    results.append(MonthlyStat(**dict(zip(columns, row))))

            return results

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except Exception as e:
        logger.error(f"Unexpected error in get_monthly_stats: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


# ============================================================================
# TEST ENDPOINTS
# ============================================================================

@router.get("/test")
async def test_endpoint():
    """
    Test endpoint to verify router is working
    """
    return {
        "message": "Statistics router is working!",
        "timestamp": datetime.now().isoformat(),
        "endpoints": [
            "/api/statistics/dashboard",
            "/api/statistics/loans/expiring",
            "/api/statistics/fines/report",
            "/api/statistics/materials/popular",
            "/api/statistics/branches/performance",
            "/api/statistics/reservations/expiring",
            "/api/statistics/activity/daily",
            "/api/statistics/memberships/stats",
            "/api/statistics/patrons/at-risk",
            "/api/statistics/stats/monthly"
        ]
    }


@router.get("/health")
async def health_check(auth: dict = Depends(require_authentication)):
    """
    Health check for statistics module
    """
    return {
        "status": "healthy",
        "user": auth["username"],
        "roles": auth["roles"],
        "timestamp": datetime.now().isoformat()
    }


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