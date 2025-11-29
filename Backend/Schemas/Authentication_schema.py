from pydantic import Field, field_validator
from typing import Optional

from .Base_Schema import  StatusResponse, BaseRequest

class LoginRequest(BaseRequest):
    username: str = Field(..., min_length=1, max_length=50, description="Username")
    password: str = Field(..., min_length=1, max_length=100, description="Password")

class LoginResponse(StatusResponse):
    session_id: Optional[str] = Field(None, description="Session ID if login successful")
    user_id: Optional[int] = Field(None, description="User ID if login successful")

class LogoutRequest(BaseRequest):
    session_id: str = Field(..., min_length=1, max_length=100, description="Session ID to logout")

class ChangePasswordRequest(BaseRequest):
    user_id: int = Field(..., gt=0, description="User ID")
    old_password: str = Field(..., min_length=1, max_length=100, description="Current password")
    new_password: str = Field(..., min_length=8, max_length=100, description="New password")

    @field_validator('new_password')
    def validate_password_strength(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        # Add more password strength validations as needed
        return v