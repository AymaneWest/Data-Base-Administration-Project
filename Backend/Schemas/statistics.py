# Schemas/statistics.py
from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from enum import Enum
import sys

# ============================================================================
# ENUMS - Define separately to avoid issues
# ============================================================================

class AlertLevel(str, Enum):
    DUE_TODAY = "DUE_TODAY"
    DUE_TOMORROW = "DUE_TOMORROW"
    DUE_SOON = "DUE_SOON"

class RiskCategory(str, Enum):
    BLOCKED = "BLOCKED"
    SUSPENDED = "SUSPENDED"
    LOST_ITEMS = "LOST_ITEMS"
    HIGH_FINES = "HIGH_FINES"
    MULTIPLE_OVERDUE = "MULTIPLE_OVERDUE"
    MODERATE_FINES = "MODERATE_FINES"
    LOW_RISK = "LOW_RISK"

class FineStatus(str, Enum):
    UNPAID = "Unpaid"
    PAID = "Paid"
    PARTIALLY_PAID = "Partially Paid"
    WAIVED = "Waived"

class MaterialType(str, Enum):
    BOOK = "Book"
    EBOOK = "EBook"
    AUDIOBOOK = "Audiobook"
    DVD = "DVD"
    CD = "CD"
    MAGAZINE = "Magazine"
    JOURNAL = "Journal"

# ============================================================================
# SECTION 1: DASHBOARD SCHEMAS
# ============================================================================

class DashboardStats(BaseModel):
    total_patrons: int = 0
    active_patrons: int = 0
    suspended_patrons: int = 0
    expired_patrons: int = 0
    new_patrons_today: int = 0
    total_active_loans: int = 0
    overdue_loans: int = 0
    checkouts_today: int = 0
    returns_today: int = 0
    loans_due_soon: int = 0
    total_materials: int = 0
    total_copies: int = 0
    available_copies: int = 0
    new_releases: int = 0
    lost_items: int = 0
    damaged_items: int = 0
    pending_reservations: int = 0
    ready_reservations: int = 0
    expired_reservations: int = 0
    total_unpaid_fines: float = 0.0
    fines_collected_today: float = 0.0
    unpaid_fine_count: int = 0
    total_branches: int = 0
    active_staff: int = 0

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 2: PATRON DETAILS SCHEMAS
# ============================================================================

class PatronInfo(BaseModel):
    patron_id: int
    card_number: str
    full_name: str
    email: str
    phone: str
    address: Optional[str] = None
    date_of_birth: Optional[date] = None
    age: Optional[int] = None
    membership_type: str
    registration_date: date
    membership_expiry: date
    membership_status: str
    days_until_expiry: int
    account_status: str
    total_fines_owed: float
    max_borrow_limit: int
    registered_branch: Optional[str] = None
    current_loans: int
    total_loans_history: int
    active_reservations: int

    class Config:
        from_attributes = True

class PatronLoan(BaseModel):
    loan_id: int
    title: str
    material_type: str
    barcode: str
    checkout_date: datetime
    due_date: datetime
    return_date: Optional[datetime] = None
    renewal_count: int
    loan_status: str
    days_overdue: int
    days_remaining: Optional[int] = None
    branch_name: Optional[str] = None
    checkout_staff: Optional[str] = None

    class Config:
        from_attributes = True

class PatronFine(BaseModel):
    fine_id: int
    fine_type: str
    amount_due: float
    amount_paid: float
    balance: float
    date_assessed: datetime
    payment_date: Optional[datetime] = None
    fine_status: str
    payment_method: Optional[str] = None
    days_unpaid: int
    related_material: Optional[str] = None

    class Config:
        from_attributes = True

class PatronReservation(BaseModel):
    reservation_id: int
    title: str
    material_type: str
    reservation_date: datetime
    reservation_status: str
    queue_position: int
    notification_date: Optional[datetime] = None
    pickup_deadline: Optional[datetime] = None
    days_to_pickup: Optional[int] = None

    class Config:
        from_attributes = True

class PatronDetailsResponse(BaseModel):
    patron_info: PatronInfo
    loans: List[PatronLoan]
    fines: List[PatronFine]
    reservations: List[PatronReservation]

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 3: EXPIRING LOANS SCHEMAS
# ============================================================================

class ExpiringLoan(BaseModel):
    loan_id: int
    patron_id: int
    card_number: str
    patron_name: str
    email: str
    phone: str
    title: str
    material_type: str
    barcode: str
    checkout_date: datetime
    due_date: datetime
    days_until_due: int
    renewal_count: int
    renewal_status: str
    branch_name: Optional[str] = None
    alert_level: AlertLevel

    class Config:
        from_attributes = True

class ExpiringLoansRequest(BaseModel):
    days_ahead: Optional[int] = Field(default=3, ge=1, le=30)
    branch_id: Optional[int] = None

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 4: FINES REPORT SCHEMAS
# ============================================================================

class FineReport(BaseModel):
    fine_id: int
    patron_id: int
    card_number: str
    patron_name: str
    email: str
    fine_type: str
    amount_due: float
    amount_paid: float
    balance: float
    date_assessed: datetime
    payment_date: Optional[datetime] = None
    fine_status: str
    payment_method: Optional[str] = None
    days_since_assessed: int
    status_indicator: str
    related_material: Optional[str] = None
    branch_name: Optional[str] = None
    assessed_by: Optional[str] = None
    waived_by: Optional[str] = None
    waiver_reason: Optional[str] = None

    class Config:
        from_attributes = True

# Request model for fines report
class FinesReportRequest(BaseModel):
    status_filter: str = "ALL"  # Changed from Enum to string to avoid issues
    branch_id: Optional[int] = None
    date_from: Optional[date] = None
    date_to: Optional[date] = None

    @validator('date_to', pre=True, always=True)
    def set_date_to(cls, v):
        if v is None:
            return date.today()
        return v

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 5: POPULAR MATERIALS SCHEMAS
# ============================================================================

class PopularMaterial(BaseModel):
    material_id: int
    title: str
    subtitle: Optional[str] = None
    material_type: str
    isbn: Optional[str] = None
    publication_year: Optional[int] = None
    publisher_name: Optional[str] = None
    total_loans: int
    unique_borrowers: int
    total_copies: int
    available_copies: int
    utilization_rate: float
    loans_per_copy: float
    last_checkout: Optional[datetime] = None
    availability_status: str
    pending_reservations: int

    class Config:
        from_attributes = True

class PopularMaterialsRequest(BaseModel):
    top_n: Optional[int] = Field(default=10, ge=1, le=100)
    material_type: Optional[str] = None  # Changed from Enum to string
    period_days: Optional[int] = Field(default=30, ge=1, le=365)

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 6: BRANCH PERFORMANCE SCHEMAS
# ============================================================================

class BranchPerformance(BaseModel):
    branch_id: int
    branch_name: str
    address: str
    phone: str
    branch_capacity: Optional[int] = None
    active_staff: int
    total_patrons: int
    active_patrons: int
    total_copies: int
    available_copies: int
    period_checkouts: int
    current_active_loans: int
    overdue_items: int
    utilization_percentage: float
    unpaid_fines: float

    class Config:
        from_attributes = True

class BranchPerformanceRequest(BaseModel):
    date_from: Optional[date] = None
    date_to: Optional[date] = None

    @validator('date_from', pre=True, always=True)
    def set_date_from(cls, v):
        if v is None:
            today = date.today()
            return date(today.year, today.month, 1)
        return v

    @validator('date_to', pre=True, always=True)
    def set_date_to(cls, v):
        if v is None:
            return date.today()
        return v

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 7: EXPIRING RESERVATIONS SCHEMAS
# ============================================================================

class ExpiringReservation(BaseModel):
    reservation_id: int
    patron_id: int
    card_number: str
    patron_name: str
    email: str
    phone: str
    title: str
    material_type: str
    reservation_date: datetime
    notification_date: Optional[datetime] = None
    pickup_deadline: datetime
    days_until_expiry: int
    reserved_copy: Optional[str] = None
    branch_name: Optional[str] = None
    alert_status: str

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 8: DAILY ACTIVITY SCHEMAS
# ============================================================================

class DailyActivity(BaseModel):
    activity_type: str
    count: int
    total_amount: Optional[float] = None

    class Config:
        from_attributes = True

class DailyActivityRequest(BaseModel):
    date: Optional[date] = None
    branch_id: Optional[int] = None

    @validator('date', pre=True, always=True)
    def set_date(cls, v):
        if v is None:
            return date.today()
        return v

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 9: MEMBERSHIP STATS SCHEMAS
# ============================================================================

class MembershipStat(BaseModel):
    membership_type: str
    total_members: int
    active_members: int
    expired_members: int
    total_loans: int
    active_loans: int
    total_fines_owed: float
    avg_fines_per_member: float
    active_reservations: int

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 10: AT-RISK PATRONS SCHEMAS
# ============================================================================

class AtRiskPatron(BaseModel):
    patron_id: int
    card_number: str
    patron_name: str
    email: str
    phone: str
    membership_type: str
    account_status: str
    overdue_items: int
    max_days_overdue: Optional[int] = None
    total_fines_owed: float
    unpaid_fine_count: int
    lost_items: int
    risk_score: float
    risk_category: RiskCategory

    class Config:
        from_attributes = True

class AtRiskPatronsRequest(BaseModel):
    branch_id: Optional[int] = None

    class Config:
        from_attributes = True

# ============================================================================
# SECTION 11: MONTHLY STATS SCHEMAS
# ============================================================================

class MonthlyStat(BaseModel):
    metric: str
    count_value: int

    class Config:
        from_attributes = True

class MonthlyStatsRequest(BaseModel):
    month: Optional[int] = None
    year: Optional[int] = None

    @validator('month', pre=True, always=True)
    def set_month(cls, v):
        if v is None:
            return datetime.now().month
        return v

    @validator('year', pre=True, always=True)
    def set_year(cls, v):
        if v is None:
            return datetime.now().year
        return v

    class Config:
        from_attributes = True

# ============================================================================
# GENERIC RESPONSES
# ============================================================================

class ErrorResponse(BaseModel):
    error: str
    details: Optional[str] = None
    code: Optional[str] = None

    class Config:
        from_attributes = True

class SuccessResponse(BaseModel):
    success: bool = True
    message: str
    data: Optional[Dict[str, Any]] = None

    class Config:
        from_attributes = True