from pydantic import Field
from typing import Optional
from .Base_Schema import BaseRequest, StatusResponse

class PasswordHashRequest(BaseRequest):
    password: str = Field(..., min_length=1, max_length=100, description="Password to hash")

class PasswordHashResponse(StatusResponse):
    password_hash: Optional[str] = Field(None, description="Hashed password")

class PasswordVerifyRequest(BaseRequest):
    password: str = Field(..., min_length=1, max_length=100, description="Plain text password")
    password_hash: str = Field(..., min_length=1, max_length=255, description="Hashed password")

class PasswordVerifyResponse(StatusResponse):
    is_match: bool = Field(..., description="Whether password matches hash")

class SessionCleanupResponse(StatusResponse):
    cleaned_count: int = Field(..., ge=0, description="Number of sessions cleaned")