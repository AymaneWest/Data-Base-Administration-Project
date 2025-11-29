# main.py
from fastapi import FastAPI
from contextlib import asynccontextmanager
from database import create_pool, close_pool
from Routes import Auth_route, users_route, Library_Management_route

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await create_pool()
    print("Database pool created successfully")
    yield
    # Shutdown
    await close_pool()
    print("Database pool closed")

app = FastAPI(
    title="Library Management System API",
    description="Comprehensive API for library management system with OracleDB backend",
    version="1.0.0",
    lifespan=lifespan
)

# Include routers
app.include_router(Auth_route.router)
app.include_router(users_route.router)
app.include_router(Library_Management_route.router)

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
        "database": "connected"  # You might want to add actual database health check
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )