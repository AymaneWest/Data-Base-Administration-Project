from fastapi import APIRouter, Depends, HTTPException
from database.connection import get_admin_connection, get_role_based_connection
from dependencies.auth import require_authentication
import oracledb
import logging
from Schemas.Authentication_schema import LoginRequest, LoginResponse, LogoutRequest, ChangePasswordRequest
from Schemas.Base_Schema import StatusResponse
from Schemas.Session_schema import SessionValidationRequest, SessionValidationResponse
from Schemas.password_schemas import (
    PasswordHashRequest, PasswordHashResponse,
    PasswordVerifyRequest, PasswordVerifyResponse
)

logger = logging.getLogger(__name__)

# ⭐ NO dependencies on router - login should be public
# Other endpoints use manual Depends(require_authentication)
router = APIRouter(prefix="/auth", tags=["authentication"])


@router.post("/login", response_model=LoginResponse)
async def login(login_data: LoginRequest):
    """
    Login endpoint - NO AUTHENTICATION REQUIRED
    Uses ADMIN connection to call sp_authenticate_user
    """
    with get_admin_connection() as conn:
        cursor = conn.cursor()

        try:
            session_id = cursor.var(str)
            user_id = cursor.var(int)
            oracle_username = cursor.var(str)
            oracle_password = cursor.var(str)
            user_roles = cursor.var(str)
            success = cursor.var(int)
            message = cursor.var(str)

            # Call your custom procedure that returns Oracle credentials
            cursor.callproc("sp_authenticate_and_get_oracle_user", [
                login_data.username,
                login_data.password,
                session_id,
                user_id,
                oracle_username,
                oracle_password,
                user_roles,
                success,
                message
            ])
            logger.warning(f"Connecting as: {oracle_username=} {oracle_password=}")
            if success.getvalue() == 1:
                return LoginResponse(
                    success=True,
                    message=message.getvalue(),
                    session_id=session_id.getvalue(),
                    user_id=user_id.getvalue(),
                    oracle_username=oracle_username.getvalue(),
                    oracle_password=oracle_password.getvalue(),
                    roles=user_roles.getvalue()
                )
            else:
                raise HTTPException(
                    status_code=401,
                    detail=message.getvalue()
                )

        except oracledb.DatabaseError as e:
            error, = e.args
            logger.error(f"Login error: {error.message}")
            raise HTTPException(
                status_code=500,
                detail=f"Database error: {error.message}"
            )


@router.post("/logout", response_model=StatusResponse)
async def logout(
        logout_data: LogoutRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Logout endpoint - REQUIRES AUTHENTICATION
    Uses ADMIN connection to call sp_logout_user
    """
    with get_admin_connection() as conn:
        cursor = conn.cursor()
        try:
            success = cursor.var(int)
            message = cursor.var(str)

            cursor.callproc("sp_logout_user", [
                logout_data.session_id,
                success,
                message
            ])

            logger.info(f"User {auth['username']} logged out")

            return StatusResponse(
                success=bool(success.getvalue()),
                message=message.getvalue()
            )

        except oracledb.DatabaseError as e:
            error, = e.args
            raise HTTPException(
                status_code=500,
                detail=f"Database error: {error.message}"
            )


@router.post("/change-password", response_model=StatusResponse)
async def change_password(
        password_data: ChangePasswordRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Change password - REQUIRES AUTHENTICATION
    Uses ADMIN connection to call sp_change_password
    """
    with get_admin_connection() as conn:
        cursor = conn.cursor()
        try:
            success = cursor.var(int)
            message = cursor.var(str)

            cursor.callproc("sp_change_password", [
                auth["user_id"],  # Get from auth token
                password_data.old_password,
                password_data.new_password,
                success,
                message
            ])

            return StatusResponse(
                success=bool(success.getvalue()),
                message=message.getvalue()
            )

        except oracledb.DatabaseError as e:
            error, = e.args
            raise HTTPException(
                status_code=500,
                detail=f"Database error: {error.message}"
            )


@router.post("/validate-session", response_model=SessionValidationResponse)
async def validate_session(session_data: SessionValidationRequest):
    """
    Validate session - NO AUTHENTICATION REQUIRED (it validates the token itself)
    Uses ADMIN connection to call sp_validate_session
    """
    with get_admin_connection() as conn:
        cursor = conn.cursor()
        try:
            is_valid = cursor.var(int)
            user_id = cursor.var(int)
            message = cursor.var(str)

            cursor.callproc("sp_validate_session", [
                session_data.session_id,
                is_valid,
                user_id,
                message
            ])

            return SessionValidationResponse(
                success=True,
                message=message.getvalue(),
                is_valid=bool(is_valid.getvalue()),
                user_id=user_id.getvalue() if is_valid.getvalue() else None
            )

        except oracledb.DatabaseError as e:
            error, = e.args
            raise HTTPException(
                status_code=500,
                detail=f"Database error: {error.message}"
            )


@router.post("/hash-password", response_model=PasswordHashResponse)
async def hash_password(
        request: PasswordHashRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Hash password - REQUIRES AUTHENTICATION
    Uses ADMIN connection to call fn_hash_password
    """
    with get_admin_connection() as conn:
        cursor = conn.cursor()
        try:
            hashed = cursor.callfunc(
                "fn_hash_password",
                str,
                [request.password]
            )

            return PasswordHashResponse(
                success=True,
                message="Password hashed successfully",
                password_hash=hashed
            )

        except oracledb.DatabaseError as e:
            error, = e.args
            raise HTTPException(
                status_code=500,
                detail=f"Database error: {error.message}"
            )


@router.post("/verify-password", response_model=PasswordVerifyResponse)
async def verify_password(
        request: PasswordVerifyRequest,
        auth: dict = Depends(require_authentication)
):
    """
    Verify password - REQUIRES AUTHENTICATION
    Uses ADMIN connection to call fn_verify_password
    """
    with get_admin_connection() as conn:
        cursor = conn.cursor()
        try:
            is_match = cursor.callfunc(
                "fn_verify_password",
                int,
                [request.password, request.password_hash]
            )

            return PasswordVerifyResponse(
                success=True,
                message="Password verification completed",
                is_match=bool(is_match)
            )

        except oracledb.DatabaseError as e:
            error, = e.args
            raise HTTPException(
                status_code=500,
                detail=f"Database error: {error.message}"
            )
