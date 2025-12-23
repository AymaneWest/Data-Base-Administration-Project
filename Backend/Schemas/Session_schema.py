from pydantic import Field
from typing import Optional
from .Base_Schema import  StatusResponse, BaseRequest


class SessionValidationRequest(BaseRequest):
    session_id: str = Field(..., min_length=1, max_length=100, description="Session ID to validate")

class SessionValidationResponse(StatusResponse):
    is_valid: bool = Field(..., description="Whether session is valid")
    user_id: Optional[int] = Field(None, description="User ID if session valid")

class SessionRemainingTimeRequest(BaseRequest):
    session_id: str = Field(..., min_length=1, max_length=100, description="Session ID")

class SessionRemainingTimeResponse(StatusResponse):
    remaining_minutes: int = Field(..., ge=0, description="Minutes until session expires")