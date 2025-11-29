# routes/users.py
from fastapi import APIRouter, Depends, HTTPException
from database import get_db
from auth import get_current_user, require_permission, require_role
import oracledb
from Schemas.User_schema import UserStatusRequest, UserStatusResponse, UserRolesRequest, UserRolesResponse
from Schemas.permissions_roles_schema import  PermissionCheckRequest, PermissionCheckResponse, RoleCheckRequest, RoleCheckResponse, AssignRoleRequest, RevokeRoleRequest
from Schemas.Base_Schema import  StatusResponse


router = APIRouter(prefix="/users", tags=["users"])


@router.get("/{user_id}/status", response_model=UserStatusResponse)
async def get_user_status(
        user_id: int,
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        is_active = cursor.callfunc("fn_is_user_active", int, [user_id])
        is_locked = cursor.callfunc("fn_is_account_locked", int, [user_id])

        return UserStatusResponse(
            success=True,
            message="User status retrieved",
            is_active=bool(is_active),
            is_locked=bool(is_locked)
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.get("/{user_id}/roles", response_model=UserRolesResponse)
async def get_user_roles(
        user_id: int,
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
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
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/check-permission", response_model=PermissionCheckResponse)
async def check_user_permission(
        request: PermissionCheckRequest,
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        has_permission = cursor.callfunc("fn_has_permission", int, [request.user_id, request.permission_code])

        return PermissionCheckResponse(
            success=True,
            message="Permission check completed",
            has_permission=bool(has_permission)
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/check-role", response_model=RoleCheckResponse)
async def check_user_role(
        request: RoleCheckRequest,
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        has_role = cursor.callfunc("fn_has_role", int, [request.user_id, request.role_code])

        return RoleCheckResponse(
            success=True,
            message="Role check completed",
            has_role=bool(has_role)
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/assign-role", response_model=StatusResponse)
async def assign_role_to_user(
        request: AssignRoleRequest,
        user_id: int = Depends(require_permission("MANAGE_USERS")),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        success = cursor.var(int)
        message = cursor.var(str, 500)

        cursor.callproc("sp_assign_role_to_user", [
            request.user_id,
            request.role_id,
            user_id,  # current user performing the action
            success,
            message
        ])

        return StatusResponse(
            success=bool(success.getvalue()),
            message=message.getvalue()
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/revoke-role", response_model=StatusResponse)
async def revoke_role_from_user(
        request: RevokeRoleRequest,
        user_id: int = Depends(require_permission("MANAGE_USERS")),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        success = cursor.var(int)
        message = cursor.var(str, 500)

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
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()