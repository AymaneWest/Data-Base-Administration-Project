from pydantic import Field
from .Base_Schema import  StatusResponse, BaseRequest

class PermissionCheckRequest(BaseRequest):
    user_id: int = Field(..., gt=0, description="User ID")
    permission_code: str = Field(..., min_length=1, max_length=50, description="Permission code")

class PermissionCheckResponse(StatusResponse):
    has_permission: bool = Field(..., description="Whether user has the permission")

class RoleCheckRequest(BaseRequest):
    user_id: int = Field(..., gt=0, description="User ID")
    role_code: str = Field(..., min_length=1, max_length=50, description="Role code")

class RoleCheckResponse(StatusResponse):
    has_role: bool = Field(..., description="Whether user has the role")

class AssignRoleRequest(BaseRequest):
    user_id: int = Field(..., gt=0, description="User ID to assign role to")
    role_id: int = Field(..., gt=0, description="Role ID to assign")
    assigned_by_user_id: int = Field(..., gt=0, description="User ID performing the assignment")

class RevokeRoleRequest(BaseRequest):
    user_id: int = Field(..., gt=0, description="User ID to revoke role from")
    role_id: int = Field(..., gt=0, description="Role ID to revoke")