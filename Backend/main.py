# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from Routes import Auth_route, users_route, Library_Management_route

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
app.include_router(users_route.router)           # All protected automatically
app.include_router(Library_Management_route.router)         # All protected automatically

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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000,reload=True)
