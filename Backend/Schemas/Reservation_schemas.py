from pydantic import BaseModel, Field, validator, condecimal
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from .Base_Schema import BaseRequest, StatusResponse, MembershipType



class PlaceReservationRequest(BaseRequest):
    material_id: int = Field(..., gt=0, description="Material ID")
    patron_id: int = Field(..., gt=0, description="Patron ID")

class PlaceReservationResponse(StatusResponse):
    reservation_id: int = Field(..., gt=0, description="New reservation ID")
    queue_position: int = Field(..., ge=1, description="Position in queue")

class CancelReservationRequest(BaseRequest):
    reservation_id: int = Field(..., gt=0, description="Reservation ID")
    patron_id: int = Field(..., gt=0, description="Patron ID")

class FulfillReservationRequest(BaseRequest):
    reservation_id: int = Field(..., gt=0, description="Reservation ID")
    copy_id: int = Field(..., gt=0, description="Copy ID")
    staff_id: int = Field(..., gt=0, description="Staff ID")

class FulfillReservationResponse(StatusResponse):
    pickup_deadline: date = Field(..., description="Pickup deadline date")