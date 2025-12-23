from pydantic import BaseModel, Field, validator, condecimal
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from .Base_Schema import BaseRequest, StatusResponse, MembershipType, FineStatus, PaymentMethod, FineType


class PayFineRequest(BaseRequest):
    fine_id: int = Field(..., gt=0, description="Fine ID")
    payment_amount: Decimal = Field(..., gt=0, description="Payment amount")
    payment_method: PaymentMethod = Field(..., description="Payment method")
    staff_id: int = Field(..., gt=0, description="Staff ID processing payment")

class PayFineResponse(StatusResponse):
    remaining_balance: Decimal = Field(..., ge=0, description="Remaining balance")
    new_fine_status: FineStatus = Field(..., description="Updated fine status")

class WaiveFineRequest(BaseRequest):
    fine_id: int = Field(..., gt=0, description="Fine ID")
    waiver_reason: str = Field(..., min_length=10, max_length=1000, description="Waiver reason")
    staff_id: int = Field(..., gt=0, description="Staff ID")

class WaiveFineResponse(StatusResponse):
    waived_amount: Decimal = Field(..., ge=0, description="Amount waived")

class AssessFineRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID")
    loan_id: Optional[int] = Field(None, gt=0, description="Associated loan ID")
    fine_type: FineType = Field(..., description="Type of fine")
    amount: Decimal = Field(..., gt=0, description="Fine amount")
    staff_id: int = Field(..., gt=0, description="Staff ID assessing fine")

class AssessFineResponse(StatusResponse):
    fine_id: int = Field(..., gt=0, description="New fine ID")