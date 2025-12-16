from pydantic import BaseModel, Field, validator, condecimal
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from .Base_Schema import BaseRequest, StatusResponse, MembershipType


class PatronStatisticsRequest(BaseRequest):
    patron_id: int = Field(..., gt=0, description="Patron ID")

class PatronStatisticsResponse(BaseModel):
    success: bool
    message: str
    patron_id: int
    statistics_text: str
    active_loans: int
    overdue_loans: int
    total_fines: float
    reservations: int
    executed_by_oracle_user: Optional[str] = None

class OverdueCountRequest(BaseRequest):
    branch_id: Optional[int] = Field(None, gt=0, description="Branch ID filter")

class OverdueCountResponse(StatusResponse):
    overdue_count: int = Field(..., ge=0, description="Number of overdue items")

class TotalFinesRequest(BaseRequest):
    patron_id: Optional[int] = Field(None, gt=0, description="Patron ID filter")

class TotalFinesResponse(StatusResponse):
    total_fines: Decimal = Field(..., ge=0, description="Total fines amount")

class MaterialAvailabilityRequest(BaseRequest):
    material_id: int = Field(..., gt=0, description="Material ID")

class MaterialAvailabilityResponse(StatusResponse):
    availability_status: str = Field(..., description="Availability status text")
    total_copies: int = Field(..., ge=0, description="Total copies")
    available_copies: int = Field(..., ge=0, description="Available copies")