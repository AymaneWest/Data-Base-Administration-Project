from pydantic import Field, validator
from typing import Optional, List
from .Base_Schema import  StatusResponse, BaseRequest

class UserStatusRequest(BaseRequest):
    user_id: int = Field(..., gt=0, description="User ID")

class UserStatusResponse(StatusResponse):
    is_active: Optional[bool] = Field(None, description="Whether user account is active")
    is_locked: Optional[bool] = Field(None, description="Whether user account is locked")

class UserRolesRequest(BaseRequest):
    user_id: int = Field(..., gt=0, description="User ID")

class UserRolesResponse(StatusResponse):
    roles: str = Field(..., description="Comma-separated list of roles")
    roles_list: List[str] = Field(..., description="List of roles")

    @validator('roles_list', pre=True, always=True)
    def parse_roles_list(cls, v, values):
        if 'roles' in values and values['roles']:
            return values['roles'].split(',')
        return []