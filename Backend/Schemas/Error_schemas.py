from pydantic import BaseModel
from typing import Optional, List, Any
from datetime import  datetime

class ErrorResponse(BaseModel):
    error: str
    details: Optional[str] = None
    error_code: Optional[str] = None

class ValidationError(BaseModel):
    loc: List[str]
    msg: str
    type: str

class HTTPErrorResponse(BaseModel):
    detail: str

class LibraryErrorResponse(BaseModel):
    error_code: str
    error_message: str
    details: Optional[str] = None
    timestamp: datetime

class ValidationErrorDetail(BaseModel):
    field: str
    message: str
    value: Any

class BulkValidationError(BaseModel):
    errors: List[ValidationErrorDetail]