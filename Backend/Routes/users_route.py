from fastapi import APIRouter, Depends, HTTPException
from database.connection import get_admin_connection, get_role_based_connection, handle_oracle_error
from dependencies.auth import require_authentication
import oracledb
import logging
from Schemas.User_schema import UserStatusRequest, UserStatusResponse, UserRolesRequest, UserRolesResponse
from Schemas.permissions_roles_schema import (
    PermissionCheckRequest, PermissionCheckResponse,
    RoleCheckRequest, RoleCheckResponse,
    AssignRoleRequest, RevokeRoleRequest
)
from Schemas.Base_Schema import StatusResponse

logger = logging.getLogger(__name__)

# ⭐ ALL endpoints automatically protected via router dependencies
router = APIRouter(
    prefix="/users",
    tags=["users"],
    dependencies=[Depends(require_authentication)]
)


@router.get("/{user_id}/status", response_model=UserStatusResponse)
async def get_user_status(
        user_id: int,
        auth: dict = Depends(require_authentication)
):
    """
    Get user status - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection (user's Oracle user based on their role)
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Call functions using role-based connection
                is_active = cursor.callfunc("fn_is_user_active", int, [user_id])
                is_locked = cursor.callfunc("fn_is_account_locked", int, [user_id])

                return UserStatusResponse(
                    success=True,
                    message="User status retrieved",
                    is_active=bool(is_active),
                    is_locked=bool(is_locked)
                )

            except oracledb.DatabaseError as e:
                # This will catch ORA-00942 if user doesn't have access
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


@router.get("/{user_id}/roles", response_model=UserRolesResponse)
async def get_user_roles(
        user_id: int,
        auth: dict = Depends(require_authentication)
):
    """
    Get user roles - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                roles = cursor.callfunc("fn_get_user_roles", str, [user_id])
                roles_list = roles.split(',') if roles != 'NO_ROLES' else []

                return UserRolesResponse(
                    success=True,
                    message="User roles retrieved",
                    roles=roles,
                    roles_list=roles_list
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


@router.post("/check-permission", response_model=PermissionCheckResponse)
async def check_user_permission(
        request: PermissionCheckRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Check user permission - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                has_permission = cursor.callfunc(
                    "fn_has_permission",
                    int,
                    [request.user_id, request.permission_code]
                )

                return PermissionCheckResponse(
                    success=True,
                    message="Permission check completed",
                    has_permission=bool(has_permission)
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


@router.post("/check-role", response_model=RoleCheckResponse)
async def check_user_role(
        request: RoleCheckRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Check user role - AUTOMATICALLY PROTECTED
    Uses ROLE-BASED connection
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                has_role = cursor.callfunc(
                    "fn_has_role",
                    int,
                    [request.user_id, request.role_code]
                )

                return RoleCheckResponse(
                    success=True,
                    message="Role check completed",
                    has_role=bool(has_role)
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


@router.post("/assign-role", response_model=StatusResponse)
async def assign_role_to_user(
        request: AssignRoleRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Assign role - AUTOMATICALLY PROTECTED
    Additional check: Only admins can assign roles
    Uses ROLE-BASED connection
    """
    # Check if user has admin role
    if "ROLE_SYS_ADMIN" not in auth["roles"]:
        raise HTTPException(
            status_code=403,
            detail="Only administrators can assign roles"
        )

    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                success = cursor.var(int)
                message = cursor.var(str)

                cursor.callproc("sp_assign_role_to_user", [
                    request.user_id,
                    request.role_id,
                    auth["user_id"],  # Current user performing the action
                    success,
                    message
                ])

                return StatusResponse(
                    success=bool(success.getvalue()),
                    message=message.getvalue()
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


@router.post("/revoke-role", response_model=StatusResponse)
async def revoke_role_from_user(
        request: RevokeRoleRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Revoke role - AUTOMATICALLY PROTECTED
    Additional check: Only admins can revoke roles
    Uses ROLE-BASED connection
    """
    # Check if user has admin role
    if "ROLE_SYS_ADMIN" not in auth["roles"]:
        raise HTTPException(
            status_code=403,
            detail="Only administrators can revoke roles"
        )

    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                success = cursor.var(int)
                message = cursor.var(str)

                cursor.callproc("sp_revoke_role_from_user", [
                    request.user_id,
                    request.role_id,
                    success,
                    message
                ])

                return StatusResponse(
                    success=bool(success.getvalue()),
                    message=message.getvalue()
                )

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise