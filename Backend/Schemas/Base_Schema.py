from pydantic import BaseModel
from enum import Enum

class StatusResponse(BaseModel):
    success: bool
    message: str

class BaseRequest(BaseModel):
    class Config:
        from_attributes = True

# Enum Definitions
class MembershipType(str, Enum):
    VIP = "VIP"
    PREMIUM = "Premium"
    STUDENT = "Student"
    CHILD = "Child"
    STANDARD = "Standard"

class MaterialType(str, Enum):
    BOOK = "Book"
    DVD = "DVD"
    MAGAZINE = "Magazine"
    E_BOOK = "E-book"
    AUDIOBOOK = "Audiobook"
    JOURNAL = "Journal"
    NEWSPAPER = "Newspaper"
    CD = "CD"
    GAME = "Game"

class AccountStatus(str, Enum):
    ACTIVE = "Active"
    SUSPENDED = "Suspended"
    BLOCKED = "Blocked"
    EXPIRED = "Expired"

class CopyStatus(str, Enum):
    AVAILABLE = "Available"
    CHECKED_OUT = "Checked Out"
    RESERVED = "Reserved"
    LOST = "Lost"
    DAMAGED = "Damaged"

class LoanStatus(str, Enum):
    ACTIVE = "Active"
    RETURNED = "Returned"
    LOST = "Lost"
    OVERDUE = "Overdue"

class ReservationStatus(str, Enum):
    PENDING = "Pending"
    READY = "Ready"
    CANCELLED = "Cancelled"
    EXPIRED = "Expired"
    FULFILLED = "Fulfilled"

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

class PaymentMethod(str, Enum):
    CASH = "Cash"
    CREDIT_CARD = "Credit Card"
    DEBIT_CARD = "Debit Card"
    ONLINE = "Online"
    CHECK = "Check"