from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from datetime import date
from decimal import Decimal
from .Base_Schema import BaseRequest, StatusResponse, MembershipType, AccountStatus, LoanStatus, MaterialType

class UserSessionInfo(BaseModel):
    user_id: int
    username: str
    is_active: bool
    is_locked: bool
    roles: List[str]
    session_valid: bool
    session_remaining_minutes: int

class UserPermissionsResponse(StatusResponse):
    permissions: Dict[str, bool] = Field(..., description="Dictionary of permission codes and their status")
    roles: List[str] = Field(..., description="List of user roles")

class BulkPermissionCheckRequest(BaseRequest):
    user_id: int = Field(..., gt=0, description="User ID")
    permission_codes: List[str] = Field(..., min_items=1, description="List of permission codes to check")

class BulkPermissionCheckResponse(StatusResponse):
    permissions: Dict[str, bool] = Field(..., description="Dictionary with permission codes and their status")

class PatronDetailResponse(BaseModel):
    patron_id: int
    card_number: str
    first_name: str
    last_name: str
    email: str
    phone: str
    membership_type: MembershipType
    account_status: AccountStatus
    membership_expiry: date
    total_fines_owed: Decimal
    max_borrow_limit: int
    active_loans: int
    is_eligible: bool
    eligibility_reason: Optional[str]

class LoanDetailResponse(BaseModel):
    loan_id: int
    patron_id: int
    copy_id: int
    material_title: str
    checkout_date: date
    due_date: date
    return_date: Optional[date]
    renewal_count: int
    loan_status: LoanStatus
    days_overdue: int
    potential_fine: Decimal

class MaterialDetailResponse(BaseModel):
    material_id: int
    title: str
    material_type: MaterialType
    isbn: Optional[str]
    publication_year: int
    language: str
    total_copies: int
    available_copies: int
    availability_status: str