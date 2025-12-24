# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from Routes import Auth_route, users_route, Library_Management_route, statistics_route,utility_route, patron_route, circulation_route,material_route, reservation_router, fine_route,reporting_route, batch_route, signup_route, dashboard_route
from database.connection import get_admin_connection
import oracledb
import logging
logging.basicConfig(level=logging.INFO)

app = FastAPI(
    title="Library Management System",
    description="Role-based authentication with Oracle ",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(Auth_route.router)  # Login/logout - not protected
app.include_router(users_route.router)  # All protected automatically
app.include_router(statistics_route.router)
app.include_router(Library_Management_route.router)         # All protected automatically
app.include_router(utility_route.router)
app.include_router(patron_route.router)
app.include_router(circulation_route.router)
app.include_router(material_route.router)
app.include_router(reservation_router.router)
app.include_router(fine_route.router)
app.include_router(reporting_route.router)
app.include_router(batch_route.router)
app.include_router(signup_route.router)
app.include_router(dashboard_route.router)

@app.get("/")
async def root():
    return {
        "message": "Library Management System API",
        "version": "1.0.0",
        "status": "running"
    }
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "database": "connected"
    }
@app.get("/check")
async def hello_chat():
    return {
        "message": " hello barbie"
    }

@app.get("/public/stats")
async def get_public_stats():
    """
    Public endpoint to get basic library statistics for homepage
    No authentication required
    """
    try:
        with get_admin_connection() as conn:
            cursor = conn.cursor()
            try:
                # Get total materials
                cursor.execute("SELECT COUNT(*) FROM materials")
                total_materials = cursor.fetchone()[0] or 0
                
                # Get available copies
                cursor.execute("""
                    SELECT COUNT(*) 
                    FROM copies 
                    WHERE copy_status = 'Available'
                """)
                available_copies = cursor.fetchone()[0] or 0
                
                # Get active patrons
                cursor.execute("""
                    SELECT COUNT(*) 
                    FROM patrons 
                    WHERE account_status = 'Active' 
                    AND membership_expiry >= SYSDATE
                """)
                active_patrons = cursor.fetchone()[0] or 0
                
                # Get total branches
                cursor.execute("SELECT COUNT(*) FROM branches")
                total_branches = cursor.fetchone()[0] or 0
                
                return {
                    "total_materials": total_materials,
                    "available_copies": available_copies,
                    "active_patrons": active_patrons,
                    "total_branches": total_branches
                }
            except oracledb.DatabaseError as e:
                error, = e.args
                logging.error(f"Database error in public stats: {error.message}")
                # Return default values on error
                return {
                    "total_materials": 0,
                    "available_copies": 0,
                    "active_patrons": 0,
                    "total_branches": 0
                }
    except Exception as e:
        logging.error(f"Error in public stats endpoint: {str(e)}")
        return {
            "total_materials": 0,
            "available_copies": 0,
            "active_patrons": 0,
            "total_branches": 0
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000,reload=True)
