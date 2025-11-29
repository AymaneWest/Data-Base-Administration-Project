from pydantic import BaseModel, Field, validator, condecimal
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from .Base_Schema import BaseRequest, StatusResponse, MembershipType


class CheckoutItemRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID")
    copy_id: int = Field(..., gt=0, description="Copy ID")
    staff_id: int = Field(..., gt=0, description="Staff ID performing checkout")

class CheckoutItemResponse(StatusResponse):
    loan_id: int = Field(..., gt=0, description="New loan ID")
    due_date: date = Field(..., description="Due date")

class CheckinItemRequest(BaseRequest):
    loan_id: int = Field(..., gt=0, description="Loan ID")
    staff_id: int = Field(..., gt=0, description="Staff ID performing checkin")

class CheckinItemResponse(StatusResponse):
    fine_assessed: Decimal = Field(0, ge=0, description="Fine amount assessed")
    days_overdue: int = Field(0, ge=0, description="Days overdue")

class RenewLoanRequest(BaseRequest):
    loan_id: int = Field(..., gt=0, description="Loan ID")

class RenewLoanResponse(StatusResponse):
    new_due_date: date = Field(..., description="New due date")
    renewal_count: int = Field(..., ge=0, description="Total renewal count")

class DeclareItemLostRequest(BaseRequest):
    loan_id: int = Field(..., gt=0, description="Loan ID")
    staff_id: int = Field(..., gt=0, description="Staff ID")
    replacement_cost: Decimal = Field(..., gt=0, description="Replacement cost")

class DeclareItemLostResponse(StatusResponse):
    fine_id: int = Field(..., gt=0, description="Fine ID created")
    replacement_cost: Decimal = Field(..., gt=0, description="Replacement cost charged")