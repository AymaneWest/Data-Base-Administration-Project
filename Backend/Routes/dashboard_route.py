from fastapi import APIRouter, Depends, HTTPException
from database.connection import get_role_based_connection, handle_oracle_error
from dependencies.auth import require_authentication
import oracledb
import logging

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])
logger = logging.getLogger(__name__)

@router.get("/stats")
async def get_dashboard_stats(auth: dict = Depends(require_authentication)):
    """
    Get generic dashboard stats (Admin/Staff)
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            try:
                # Query the view created in 10_create_views.sql
                cursor.execute("SELECT * FROM VIEW_DASHBOARD_STATS")
                row = cursor.fetchone() # Expecting single row view
                
                if row:
                    columns = [col[0].lower() for col in cursor.description]
                    return dict(zip(columns, row))
                return {}

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise

@router.get("/activity")
async def get_monthly_activity(auth: dict = Depends(require_authentication)):
    """
    Get monthly checkout/return activity
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute("SELECT * FROM VIEW_MONTHLY_ACTIVITY")
                columns = [col[0].lower() for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                return results

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise

@router.get("/popular-books")
async def get_popular_books(auth: dict = Depends(require_authentication)):
    """
    Get top 10 popular books
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute("SELECT * FROM VIEW_POPULAR_BOOKS")
                columns = [col[0].lower() for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                return results

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise
