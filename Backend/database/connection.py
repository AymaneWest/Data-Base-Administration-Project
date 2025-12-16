import oracledb
from contextlib import contextmanager
from fastapi import HTTPException, status
import os
import logging
from typing import Dict, Any
logger = logging.getLogger(__name__)

# Configuration
ADMIN_USER ='projet_admin' # os.getenv("ORACLE_ADMIN_USER")
ADMIN_PASSWORD ='StrongPassword123'   # os.getenv("ORACLE_ADMIN_PASSWORD")
ORACLE_DSN = os.getenv("ORACLE_DSN", "localhost:1521/XEPDB1")
print('-------------------------------------')
print("ADMIN_USER =", repr(ADMIN_USER))
print("ADMIN_PASSWORD =", repr(ADMIN_PASSWORD))
print("ORACLE_DSN =", repr(ORACLE_DSN))
print('-------------------------------------')

@contextmanager
def get_admin_connection():
    """
    Connect as admin user for authentication and session management.
    Use this for: login, logout, session validation
    """
    conn = None
    try:
        conn = oracledb.connect(
            user=ADMIN_USER,
            password=ADMIN_PASSWORD,
            dsn=ORACLE_DSN
        )
        yield conn
    except oracledb.Error as e:
        error, = e.args
        logger.error(f"Admin connection failed: {error.message}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database connection failed: {error.message}"
        )
    finally:
        if conn:
            conn.close()


@contextmanager
def get_role_based_connection(oracle_username: str, oracle_password: str):
    """
    Connect as role-based Oracle user.
    Use this for: all authenticated operations with role-specific privileges
    """
    conn = None
    # oracle_username='user_sysadmin'
    # oracle_password='SysAdminPass123'
    try:
        conn = oracledb.connect(
            user=oracle_username,
            password=oracle_password,
            dsn=ORACLE_DSN
        )
        yield conn
    except oracledb.Error as e:
        error, = e.args
        logger.error(f"Role-based connection failed for {oracle_username}: {error.message}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Oracle user connection failed: {error.message}"
        )
    finally:
        if conn:
            conn.close()


def handle_oracle_error(e: oracledb.Error, oracle_user: str) -> dict:
    """
    Handle Oracle errors and return user-friendly messages.
    This catches ORA-00942, ORA-01031, etc. and returns them in API response.
    """
    error, = e.args
    error_code = error.code
    error_message = error.message

    logger.error(f"Oracle error {error_code} for user {oracle_user}: {error_message}")

    error_responses = {
        942: {
            "message": "Access denied. You don't have permission to access this resource.",
            "detail": f"The Oracle user '{oracle_user}' does not have privileges for this operation."
        },
        1031: {
            "message": "Insufficient privileges for this operation.",
            "detail": f"Your role (connected as '{oracle_user}') does not allow this action."
        },
        1403: {
            "message": "No data found.",
            "detail": "The requested resource does not exist."
        },
        1: {
            "message": "Duplicate entry. This record already exists.",
            "detail": error_message
        }
    }

    response_data = error_responses.get(error_code, {
        "message": "Database operation failed.",
        "detail": error_message
    })

    return {
        "success": False,
        "error": response_data["message"],
        "detail": response_data["detail"],
        "oracle_error_code": f"ORA-{error_code:05d}",
        "executed_by_oracle_user": oracle_user
    }


def handle_oracle_error(error: oracledb.DatabaseError, oracle_user: str) -> Dict[str, Any]:
    """
    Handle Oracle database errors and return appropriate HTTP responses
    """
    error_code = error.args[0].code if error.args else None
    error_message = str(error)

    # Map Oracle error codes to HTTP status codes
    if error_code in [20101, 20102, 20103, 20104]:  # Patron errors
        status_code = status.HTTP_400_BAD_REQUEST
    elif error_code in [20201, 20202, 20203, 20204]:  # Circulation errors
        status_code = status.HTTP_400_BAD_REQUEST
    elif error_code == 1403:  # NO_DATA_FOUND
        status_code = status.HTTP_404_NOT_FOUND
    elif error_code == 1:  # Unique constraint violation
        status_code = status.HTTP_409_CONFLICT
    else:
        status_code = status.HTTP_500_INTERNAL_SERVER_ERROR

    return {
        "error_code": error_code,
        "error_message": error_message,
        "oracle_user": oracle_user
    }