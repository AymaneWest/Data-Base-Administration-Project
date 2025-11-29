from pydantic import BaseModel, Field, validator, condecimal
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from .Base_Schema import BaseRequest, StatusResponse, MembershipType


class ProcessOverdueNotificationsResponse(StatusResponse):
    notifications_processed: int = Field(..., ge=0, description="Number of notifications sent")

class ExpireMembershipsResponse(StatusResponse):
    memberships_expired: int = Field(..., ge=0, description="Number of expired memberships")

class CleanupExpiredReservationsResponse(StatusResponse):
    reservations_cleaned: int = Field(..., ge=0, description="Number of cleaned reservations")

class GenerateDailyReportRequest(BaseRequest):
    branch_id: Optional[int] = Field(None, gt=0, description="Branch ID filter")

class GenerateDailyReportResponse(StatusResponse):
    checkouts_today: int = Field(..., ge=0, description="Today's checkouts")
    returns_today: int = Field(..., ge=0, description="Today's returns")
    new_patrons: int = Field(..., ge=0, description="New patrons today")
    overdue_items: int = Field(..., ge=0, description="Current overdue items")
    total_unpaid_fines: Decimal = Field(..., ge=0, description="Total unpaid fines")
    report_date: date = Field(..., description="Report date")