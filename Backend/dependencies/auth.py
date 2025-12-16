from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional, List
import os
import logging
from database.connection import get_admin_connection

logger = logging.getLogger(__name__)
security = HTTPBearer()


def get_session_from_db(session_id: str) -> Optional[dict]:
    """Retrieve session from SESSION_MANAGEMENT table"""
    with get_admin_connection() as conn:
        cursor = conn.cursor()

        try:
            query = """
                SELECT 
                    sm.user_id, sm.session_status, u.username
                FROM SESSION_MANAGEMENT sm
                INNER JOIN USERS u ON sm.user_id = u.user_id
                WHERE sm.session_id = :session_id
            """
            cursor.execute(query, {"session_id": session_id})
            row = cursor.fetchone()

            if not row:
                return None

            return {
                "user_id": row[0],
                "session_status": row[1],
                "username": row[2]
            }
        except Exception as e:
            logger.error(f"Error fetching session: {str(e)}")
            return None


def get_user_oracle_credentials(user_id: int) -> dict:
    """Get Oracle username and password based on user's highest priority role"""
    with get_admin_connection() as conn:
        cursor = conn.cursor()

        query = """
            SELECT r.role_code
            FROM USER_ROLES ur
            INNER JOIN ROLES r ON ur.role_id = r.role_id
            WHERE ur.user_id = :user_id
            AND ur.is_active = 'Y'
            AND r.is_active = 'Y'
            ORDER BY 
                CASE r.role_code
                    WHEN 'ROLE_SYS_ADMIN' THEN 1
                    WHEN 'ROLE_DIRECTOR' THEN 2
                    WHEN 'ROLE_IT_SUPPORT' THEN 3
                    WHEN 'ROLE_CATALOGER' THEN 4
                    WHEN 'ROLE_CIRCULATION_CLERK' THEN 5
                    WHEN 'ROLE_PATRON' THEN 6
                    ELSE 99
                END
            FETCH FIRST 1 ROW ONLY
        """
        cursor.execute(query, {"user_id": user_id})
        row = cursor.fetchone()

        if not row:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No valid role found for user"
            )

        role_mapping = {
            'ROLE_SYS_ADMIN': {'username': 'user_sysadmin',
                               'password': os.getenv('ORACLE_SYSADMIN_PASS', 'SysAdminPass123')},
            'ROLE_DIRECTOR': {'username': 'user_director',
                              'password': os.getenv('ORACLE_DIRECTOR_PASS', 'DirectorPass123')},
            'ROLE_IT_SUPPORT': {'username': 'user_itsupport',
                                'password': os.getenv('ORACLE_ITSUPPORT_PASS', 'ITSupportPass123')},
            'ROLE_CATALOGER': {'username': 'user_cataloger',
                               'password': os.getenv('ORACLE_CATALOGER_PASS', 'CatalogPass123')},
            'ROLE_CIRCULATION_CLERK': {'username': 'user_clerk',
                                       'password': os.getenv('ORACLE_CLERK_PASS', 'ClerkPass123')},
            'ROLE_PATRON': {'username': 'PATRON', 'password': os.getenv('ORACLE_PATRON_PASS', 'PatronPass123')}
        }

        return role_mapping.get(row[0], {'username': None, 'password': None})


def get_user_roles_list(user_id: int) -> List[str]:
    """Get all roles for a user as a list"""
    with get_admin_connection() as conn:
        cursor = conn.cursor()

        query = """
            SELECT r.role_code
            FROM USER_ROLES ur
            INNER JOIN ROLES r ON ur.role_id = r.role_id
            WHERE ur.user_id = :user_id
            AND ur.is_active = 'Y'
            AND r.is_active = 'Y'
            ORDER BY r.role_code
        """
        cursor.execute(query, {"user_id": user_id})
        return [row[0] for row in cursor.fetchall()]


async def require_authentication(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Main authentication dependency - validates session and returns user info with Oracle credentials.
    Use this in all protected routes.
    """
    session_id = credentials.credentials

    # Get session from database
    session_data = get_session_from_db(session_id)
    if not session_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid session. Please login again.",
            headers={"WWW-Authenticate": "Bearer"}
        )

    # Validate session using procedure
    with get_admin_connection() as conn:
        cursor = conn.cursor()
        is_valid = cursor.var(int)
        user_id = cursor.var(int)
        message = cursor.var(str)

        try:
            cursor.callproc('sp_validate_session', [session_id, is_valid, user_id, message])

            if is_valid.getvalue() != 1:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail=message.getvalue() or "Session expired or invalid",
                    headers={"WWW-Authenticate": "Bearer"}
                )
        except Exception as e:
            logger.error(f"Session validation error: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Session validation failed"
            )

    # Get Oracle credentials and roles
    oracle_creds = get_user_oracle_credentials(session_data["user_id"])
    if not oracle_creds['username']:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No Oracle user mapping found for your role"
        )

    roles = get_user_roles_list(session_data["user_id"])

    return {
        "session_id": session_id,
        "user_id": session_data["user_id"],
        "username": session_data["username"],
        "oracle_username": oracle_creds['username'],
        "oracle_password": oracle_creds['password'],
        "roles": roles,
        "session_status": session_data["session_status"]
    }