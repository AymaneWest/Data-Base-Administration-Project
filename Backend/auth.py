# auth.py
from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from database import get_db
import oracledb
from typing import Optional

security = HTTPBearer()


async def get_current_user(
        credentials: HTTPAuthorizationCredentials = Depends(security),
        db: oracledb.Connection = Depends(get_db)
):
    """Dependency to get current user from session token"""
    token = credentials.credentials

    cursor = db.cursor()
    try:
        # Validate session using your PL/SQL function
        is_valid = cursor.callfunc("fn_is_session_valid", int, [token])

        if not is_valid:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired session"
            )

        # Get user ID from session
        user_id = cursor.callfunc("fn_get_session_user_id", int, [token])

        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found in session"
            )

        # Check if user is active
        is_active = cursor.callfunc("fn_is_user_active", int, [user_id])

        if not is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User account is inactive"
            )

        return user_id

    except oracledb.DatabaseError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )
    finally:
        cursor.close()


def require_permission(permission_code: str):
    """Dependency factory for permission checking"""

    async def permission_dependency(
            user_id: int = Depends(get_current_user),
            db: oracledb.Connection = Depends(get_db)
    ):
        cursor = db.cursor()
        try:
            has_permission = cursor.callfunc("fn_has_permission", int, [user_id, permission_code])

            if not has_permission:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Permission denied: {permission_code}"
                )

            return user_id
        except oracledb.DatabaseError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Database error: {str(e)}"
            )
        finally:
            cursor.close()

    return permission_dependency


async def require_role(role_code: str):
    """Dependency factory for role checking"""

    async def role_dependency(
            user_id: int = Depends(get_current_user),
            db: oracledb.Connection = Depends(get_db)
    ):
        cursor = db.cursor()
        try:
            has_role = cursor.callfunc("fn_has_role", int, [user_id, role_code])

            if not has_role:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Role required: {role_code}"
                )

            return user_id
        except oracledb.DatabaseError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Database error: {str(e)}"
            )
        finally:
            cursor.close()

    return role_dependency