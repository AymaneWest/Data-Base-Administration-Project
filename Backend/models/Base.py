from pydantic import BaseModel
from typing import Optional, Any
from datetime import date, datetime
from enum import Enum

class BaseResponse(BaseModel):
    success: bool
    message: str
    error_code: Optional[int] = None
    error_message: Optional[str] = None

# Enums
class MembershipType(str, Enum):
    STANDARD = "Standard"
    STUDENT = "Student"
    PREMIUM = "Premium"
    VIP = "VIP"
    CHILD = "Child"

class AccountStatus(str, Enum):
    ACTIVE = "Active"
    SUSPENDED = "Suspended"
    BLOCKED = "Blocked"
    EXPIRED = "Expired"

class LoanStatus(str, Enum):
    ACTIVE = "Active"
    RETURNED = "Returned"
    OVERDUE = "Overdue"
    LOST = "Lost"

class CopyStatus(str, Enum):
    AVAILABLE = "Available"
    CHECKED_OUT = "Checked Out"
    RESERVED = "Reserved"
    LOST = "Lost"
    DAMAGED = "Damaged"

class FineType(str, Enum):
    OVERDUE = "Overdue"
    LOST_ITEM = "Lost Item"
    DAMAGED_ITEM = "Damaged Item"
    PROCESSING_FEE = "Processing Fee"
    LATE_FEE = "Late Fee"
    OTHER = "Other"

class FineStatus(str, Enum):
    UNPAID = "Unpaid"
    PARTIALLY_PAID = "Partially Paid"
    PAID = "Paid"
    WAIVED = "Waived"