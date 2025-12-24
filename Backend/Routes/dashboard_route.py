from fastapi import APIRouter, Depends, HTTPException
from database.connection import get_role_based_connection, handle_oracle_error
from dependencies.auth import require_authentication
import oracledb
import logging
from datetime import datetime, timedelta

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

@router.get("/recent-activity")
async def get_recent_activity(auth: dict = Depends(require_authentication)):
    """
    Get recent activity feed (checkouts, returns, new members)
    Returns last 10 activities
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            try:
                # Get recent checkouts, returns, and new members
                query = """
                    SELECT 
                        'Checkout' as action_type,
                        p.first_name || ' ' || p.last_name as patron_name,
                        m.title as item_name,
                        l.checkout_date as activity_time
                    FROM loans l
                    JOIN patrons p ON l.patron_id = p.patron_id
                    JOIN copies c ON l.copy_id = c.copy_id
                    JOIN materials m ON c.material_id = m.material_id
                    WHERE l.checkout_date >= SYSDATE - 1
                    
                    UNION ALL
                    
                    SELECT 
                        'Return' as action_type,
                        p.first_name || ' ' || p.last_name as patron_name,
                        m.title as item_name,
                        l.return_date as activity_time
                    FROM loans l
                    JOIN patrons p ON l.patron_id = p.patron_id
                    JOIN copies c ON l.copy_id = c.copy_id
                    JOIN materials m ON c.material_id = m.material_id
                    WHERE l.return_date IS NOT NULL 
                    AND l.return_date >= SYSDATE - 1
                    
                    UNION ALL
                    
                    SELECT 
                        'New Member' as action_type,
                        first_name || ' ' || last_name as patron_name,
                        'Registration' as item_name,
                        registration_date as activity_time
                    FROM patrons
                    WHERE registration_date >= SYSDATE - 1
                    
                    ORDER BY activity_time DESC
                    FETCH FIRST 10 ROWS ONLY
                """
                
                cursor.execute(query)
                columns = [col[0].lower() for col in cursor.description]
                results = []
                
                for row in cursor.fetchall():
                    activity = dict(zip(columns, row))
                    # Calculate time ago
                    if activity.get('activity_time'):
                        time_diff = datetime.now() - activity['activity_time']
                        if time_diff.total_seconds() < 3600:
                            activity['time_ago'] = f"{int(time_diff.total_seconds() / 60)} mins ago"
                        elif time_diff.total_seconds() < 86400:
                            activity['time_ago'] = f"{int(time_diff.total_seconds() / 3600)} hours ago"
                        else:
                            activity['time_ago'] = f"{int(time_diff.total_seconds() / 86400)} days ago"
                    results.append(activity)
                
                return results

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise

@router.get("/alerts")
async def get_dashboard_alerts(auth: dict = Depends(require_authentication)):
    """
    Get system alerts and notifications
    Returns alerts for overdue items, holds ready for pickup, low stock items
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            alerts = []
            
            try:
                # Alert 1: Overdue items > 7 days
                cursor.execute("""
                    SELECT COUNT(*) 
                    FROM loans 
                    WHERE return_date IS NULL 
                    AND due_date < SYSDATE - 7
                """)
                overdue_count = cursor.fetchone()[0]
                if overdue_count > 0:
                    alerts.append({
                        "id": 1,
                        "type": "overdue",
                        "message": f"{overdue_count} items overdue > 7 days",
                        "severity": "high" if overdue_count > 10 else "medium",
                        "count": overdue_count
                    })
                
                # Alert 2: Holds ready for pickup
                cursor.execute("""
                    SELECT COUNT(*) 
                    FROM reservations 
                    WHERE reservation_status = 'Ready' 
                    AND expiry_date >= SYSDATE
                """)
                holds_count = cursor.fetchone()[0]
                if holds_count > 0:
                    alerts.append({
                        "id": 2,
                        "type": "pickup",
                        "message": f"{holds_count} holds ready for pickup",
                        "severity": "medium",
                        "count": holds_count
                    })
                
                # Alert 3: Low stock materials (less than 3 available copies)
                cursor.execute("""
                    SELECT m.title, COUNT(c.copy_id) as available_copies
                    FROM materials m
                    JOIN copies c ON m.material_id = c.material_id
                    WHERE c.copy_status = 'Available'
                    GROUP BY m.material_id, m.title
                    HAVING COUNT(c.copy_id) <= 2
                    FETCH FIRST 1 ROW ONLY
                """)
                low_stock = cursor.fetchone()
                if low_stock:
                    alerts.append({
                        "id": 3,
                        "type": "inventory",
                        "message": f'Low stock: "{low_stock[0]}" ({low_stock[1]} copies)',
                        "severity": "low",
                        "title": low_stock[0],
                        "copies": low_stock[1]
                    })
                
                return alerts

            except oracledb.DatabaseError as e:
                logger.error(f"Error fetching alerts: {str(e)}")
                # Return empty alerts on error rather than failing
                return []
    except HTTPException:
        raise
