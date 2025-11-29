from pydantic import BaseModel, Field, validator, condecimal
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from .Base_Schema import BaseRequest, StatusResponse, MembershipType


class AddPatronRequest(BaseRequest):
    card_number: str = Field(..., min_length=1, max_length=50, description="Unique card number")
    first_name: str = Field(..., min_length=1, max_length=100, description="First name")
    last_name: str = Field(..., min_length=1, max_length=100, description="Last name")
    email: str = Field(..., min_length=1, max_length=255, description="Email address")
    phone: str = Field(..., min_length=1, max_length=20, description="Phone number")
    address: str = Field(..., min_length=1, max_length=500, description="Address")
    date_of_birth: date = Field(..., description="Date of birth")
    membership_type: MembershipType = Field(..., description="Membership type")
    branch_id: int = Field(..., gt=0, description="Branch ID")

    @validator('email')
    def validate_email(cls, v):
        if '@' not in v:
            raise ValueError('Invalid email format')
        return v

    @validator('date_of_birth')
    def validate_date_of_birth(cls, v):
        if v >= date.today():
            raise ValueError('Date of birth must be in the past')
        return v

class AddPatronResponse(StatusResponse):
    patron_id: int = Field(..., gt=0, description="New patron ID")
    membership_expiry: date = Field(..., description="Membership expiry date")
    max_borrow_limit: int = Field(..., ge=0, description="Maximum borrow limit")

class UpdatePatronRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID")
    email: Optional[str] = Field(None, min_length=1, max_length=255, description="New email")
    phone: Optional[str] = Field(None, min_length=1, max_length=20, description="New phone")
    address: Optional[str] = Field(None, min_length=1, max_length=500, description="New address")

    @validator('email')
    def validate_email(cls, v):
        if v is not None and '@' not in v:
            raise ValueError('Invalid email format')
        return v

class RenewMembershipRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID")

class RenewMembershipResponse(StatusResponse):
    new_expiry_date: date = Field(..., description="New membership expiry date")

class SuspendPatronRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID")
    reason: str = Field(..., min_length=1, max_length=500, description="Suspension reason")
    staff_id: int = Field(..., gt=0, description="Staff ID performing the action")

class ReactivatePatronRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID")
    staff_id: int = Field(..., gt=0, description="Staff ID performing the action")