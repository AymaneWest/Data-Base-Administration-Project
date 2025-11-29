from pydantic import BaseModel, Field, validator, condecimal
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from .Base_Schema import BaseRequest, StatusResponse, MembershipType


class PatronExistsRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID to check")

class PatronExistsResponse(StatusResponse):
    exists: bool = Field(..., description="Whether patron exists")

class CalculateLoanPeriodRequest(BaseRequest):
    membership_type: MembershipType = Field(..., description="Membership type")

class CalculateLoanPeriodResponse(StatusResponse):
    loan_period_days: int = Field(..., ge=0, description="Loan period in days")

class CalculateBorrowLimitRequest(BaseRequest):
    membership_type: MembershipType = Field(..., description="Membership type")

class CalculateBorrowLimitResponse(StatusResponse):
    borrow_limit: int = Field(..., ge=0, description="Maximum borrow limit")

class ActiveLoanCountRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID")

class ActiveLoanCountResponse(StatusResponse):
    active_loans_count: int = Field(..., ge=0, description="Number of active loans")

class CalculateOverdueFineRequest(BaseRequest):
    due_date: date = Field(..., description="Due date")
    return_date: Optional[date] = Field(None, description="Return date (defaults to today)")

class CalculateOverdueFineResponse(StatusResponse):
    fine_amount: Decimal = Field(..., ge=0, description="Calculated fine amount")
    days_overdue: int = Field(..., ge=0, description="Number of days overdue")

class CheckPatronEligibilityRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID to check")

class CheckPatronEligibilityResponse(StatusResponse):
    is_eligible: bool = Field(..., description="Whether patron is eligible")
    error_message: Optional[str] = Field(None, description="Error message if not eligible")