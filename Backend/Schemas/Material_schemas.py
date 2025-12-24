from pydantic import BaseModel, Field, validator, condecimal
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from .Base_Schema import BaseRequest, StatusResponse, MembershipType, MaterialType


class AddMaterialRequest(BaseRequest):
    title: str = Field(..., min_length=1, max_length=500, description="Material title")
    subtitle: Optional[str] = Field(None, max_length=500, description="Subtitle")
    material_type: MaterialType = Field(..., description="Type of material")
    isbn: Optional[str] = Field(None, max_length=20, description="ISBN")
    publication_year: int = Field(..., ge=1000, le=2100, description="Publication year")
    publisher_id: Optional[int] = Field(None, gt=0, description="Publisher ID")
    language: str = Field("English", min_length=1, max_length=50, description="Language")
    pages: Optional[int] = Field(None, gt=0, description="Number of pages")
    description: Optional[str] = Field(None, description="Description")
    total_copies: int = Field(..., ge=0, description="Total copies")

class AddMaterialResponse(StatusResponse):
    material_id: Optional[int] = Field(None, description="New material ID")

class AddCopyRequest(BaseRequest):
    material_id: int = Field(..., gt=0, description="Material ID")
    barcode: str = Field(..., min_length=1, max_length=100, description="Barcode")
    branch_id: int = Field(..., gt=0, description="Branch ID")
    acquisition_price: Decimal = Field(0, ge=0, description="Acquisition price")

class AddCopyResponse(StatusResponse):
    copy_id: int = Field(..., gt=0, description="New copy ID")

class UpdateMaterialRequest(BaseRequest):
    material_id: int = Field(..., gt=0, description="Material ID")
    title: Optional[str] = Field(None, min_length=1, max_length=500, description="New title")
    description: Optional[str] = Field(None, description="New description")
    language: Optional[str] = Field(None, min_length=1, max_length=50, description="New language")

class DeleteMaterialRequest(BaseRequest):
    material_id: int = Field(..., gt=0, description="Material ID")
    staff_id: int = Field(..., gt=0, description="Staff ID performing deletion")