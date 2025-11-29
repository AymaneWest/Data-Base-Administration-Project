# routes/auth.py
from fastapi import APIRouter, Depends, HTTPException
from database import get_db
import oracledb
from auth import get_current_user
from Schemas.Authentication_schema import LoginRequest, LoginResponse, LogoutRequest, ChangePasswordRequest
from Schemas.Base_Schema import StatusResponse
from Schemas.Session_schema import SessionValidationRequest, SessionValidationResponse
from Schemas.password_schemas import PasswordHashRequest, PasswordHashResponse, PasswordVerifyRequest, PasswordVerifyResponse


router = APIRouter(prefix="/auth", tags=["authentication"])


@router.post("/login", response_model=LoginResponse)
async def login(login_data: LoginRequest, db: oracledb.Connection = Depends(get_db)):
    cursor = db.cursor()
    try:
        session_id = cursor.var(str)
        user_id = cursor.var(int)
        success = cursor.var(int)
        message = cursor.var(str, 500)

        cursor.callproc("sp_authenticate_user", [
            login_data.username,
            login_data.password,
            session_id,
            user_id,
            success,
            message
        ])

        if success.getvalue() == 1:
            return LoginResponse(
                success=True,
                message=message.getvalue(),
                session_id=session_id.getvalue(),
                user_id=user_id.getvalue()
            )
        else:
            raise HTTPException(status_code=401, detail=message.getvalue())

    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/logout", response_model=StatusResponse)
async def logout(logout_data: LogoutRequest, db: oracledb.Connection = Depends(get_db)):
    cursor = db.cursor()
    try:
        success = cursor.var(int)
        message = cursor.var(str, 500)

        cursor.callproc("sp_logout_user", [
            logout_data.session_id,
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


@router.post("/change-password", response_model=StatusResponse)
async def change_password(
        password_data: ChangePasswordRequest,
        user_id: int = Depends(get_current_user),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        success = cursor.var(int)
        message = cursor.var(str, 500)

        cursor.callproc("sp_change_password", [
            user_id,
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
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/validate-session", response_model=SessionValidationResponse)
async def validate_session(
        session_data: SessionValidationRequest,
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        is_valid = cursor.var(int)
        user_id = cursor.var(int)
        message = cursor.var(str, 500)

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
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/hash-password")
async def hash_password(request: PasswordHashRequest, db: oracledb.Connection = Depends(get_db)):
    cursor = db.cursor()
    try:
        hashed = cursor.callfunc("fn_hash_password", str, [request.password])
        return PasswordHashResponse(
            success=True,
            message="Password hashed successfully",
            password_hash=hashed
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/verify-password")
async def verify_password(request: PasswordVerifyRequest, db: oracledb.Connection = Depends(get_db)):
    cursor = db.cursor()
    try:
        is_match = cursor.callfunc("fn_verify_password", int, [request.password, request.password_hash])
        return PasswordVerifyResponse(
            success=True,
            message="Password verification completed",
            is_match=bool(is_match)
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()