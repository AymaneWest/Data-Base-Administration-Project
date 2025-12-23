from fastapi import APIRouter, Depends, HTTPException
from typing import Dict, Any, Optional
import oracledb
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse
from pydantic import BaseModel

router = APIRouter(prefix="/utility", tags=["Utility Functions"])


# Request/Response Models
class PatronExistsRequest(BaseModel):
    patron_id: int


class PatronExistsResponse(BaseResponse):
    exists: bool = False


class CalculateLoanPeriodRequest(BaseModel):
    membership_type: str


class CalculateLoanPeriodResponse(BaseResponse):
    loan_period_days: int = 0


class CalculateBorrowLimitRequest(BaseModel):
    membership_type: str


class CalculateBorrowLimitResponse(BaseResponse):
    borrow_limit: int = 0


class ActiveLoanCountRequest(BaseModel):
    patron_id: int


class ActiveLoanCountResponse(BaseResponse):
    active_loans: int = 0


class CalculateFineRequest(BaseModel):
    due_date: str
    return_date: Optional[str] = None


class CalculateFineResponse(BaseResponse):
    fine_amount: float = 0.0
    days_overdue: int = 0


class CheckEligibilityRequest(BaseModel):
    patron_id: int


class CheckEligibilityResponse(BaseResponse):
    is_eligible: bool = False
    error_message: Optional[str] = None


# Endpoints
@router.post("/patron-exists", response_model=PatronExistsResponse)
async def fn_check_patron_exists(
    request: PatronExistsRequest,
    auth: dict = Depends(require_authentication)
):
    """Check if a patron exists"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Call the function
                result = cursor.callfunc(
                    "fn_patron_exists",
                    bool,
                    [request.patron_id]
                )

                return PatronExistsResponse(
                    success=True,
                    message="Patron check completed",
                    exists=result
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return PatronExistsResponse(
                    success=False,
                    message="Error checking patron existence",
                    **error_response
                )

    except HTTPException:
        raise
    except Exception as e:
        return PatronExistsResponse(
            success=False,
            message=str(e),
            exists=False
        )


@router.post("/calculate-loan-period", response_model=CalculateLoanPeriodResponse)
async def calculate_loan_period(
        request: CalculateLoanPeriodRequest,
        auth: dict = Depends(require_authentication)
):
    """Calculate loan period based on membership type"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                result = cursor.callfunc(
                    "fn_calculate_loan_period",
                    int,
                    [request.membership_type]
                )

                return CalculateLoanPeriodResponse(
                    success=True,
                    message="Loan period calculated",
                    loan_period_days=result
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return CalculateLoanPeriodResponse(
                    success=False,
                    message="Error calculating loan period",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/calculate-borrow-limit", response_model=CalculateBorrowLimitResponse)
async def calculate_borrow_limit(
        request: CalculateBorrowLimitRequest,
        auth: dict = Depends(require_authentication)
):
    """Calculate borrow limit based on membership type"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                result = cursor.callfunc(
                    "fn_calculate_borrow_limit",
                    int,
                    [request.membership_type]
                )

                return CalculateBorrowLimitResponse(
                    success=True,
                    message="Borrow limit calculated",
                    borrow_limit=result
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return CalculateBorrowLimitResponse(
                    success=False,
                    message="Error calculating borrow limit",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/active-loan-count", response_model=ActiveLoanCountResponse)
async def get_active_loan_count(
        request: ActiveLoanCountRequest,
        auth: dict = Depends(require_authentication)
):
    """Get active loan count for a patron"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                result = cursor.callfunc(
                    "fn_get_active_loan_count",
                    int,
                    [request.patron_id]
                )

                return ActiveLoanCountResponse(
                    success=True,
                    message="Active loan count retrieved",
                    active_loans=result
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return ActiveLoanCountResponse(
                    success=False,
                    message="Error getting active loan count",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/calculate-fine", response_model=CalculateFineResponse)
async def calculate_overdue_fine(
        request: CalculateFineRequest,
        auth: dict = Depends(require_authentication)
):
    """Calculate overdue fine"""
    from datetime import datetime

    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Parse dates
                due_date = datetime.strptime(request.due_date, "%Y-%m-%d").date()

                if request.return_date:
                    return_date = datetime.strptime(request.return_date, "%Y-%m-%d").date()
                    result = cursor.callfunc(
                        "fn_calculate_overdue_fine",
                        float,
                        [due_date, return_date]
                    )
                else:
                    result = cursor.callfunc(
                        "fn_calculate_overdue_fine",
                        float,
                        [due_date]
                    )

                # Calculate days overdue
                days_overdue = (datetime.now().date() - due_date).days
                if days_overdue < 0:
                    days_overdue = 0

                return CalculateFineResponse(
                    success=True,
                    message="Fine calculated",
                    fine_amount=result,
                    days_overdue=days_overdue
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return CalculateFineResponse(
                    success=False,
                    message="Error calculating fine",
                    **error_response
                )

    except HTTPException:
        raise


@router.post("/check-eligibility", response_model=CheckEligibilityResponse)
async def check_patron_eligibility(
        request: CheckEligibilityRequest,
        auth: dict = Depends(require_authentication)
):
    """Check patron eligibility for borrowing"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Create OUT parameter for error message
                error_message = cursor.var(str)

                result = cursor.callfunc(
                    "fn_check_patron_eligibility",
                    bool,
                    [request.patron_id, error_message]
                )

                return CheckEligibilityResponse(
                    success=True,
                    message="Eligibility check completed",
                    is_eligible=result,
                    error_message=error_message.getvalue()
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return CheckEligibilityResponse(
                    success=False,
                    message="Error checking eligibility",
                    is_eligible=False,
                    **error_response
                )

    except HTTPException:
        raise