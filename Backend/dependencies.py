from fastapi import  Depends
from main import app
import oracledb


pool = None

@app.on_event("startup")
async def startup():
    global pool
    pool = oracledb.create_pool(
        user="your_user",
        password="your_pass",
        dsn="localhost:1521/XE",
        min=2, max=5
    )

@app.on_event("shutdown")
async def shutdown():
    pool.close()

# Dependency function
def get_db():
    connection = pool.acquire()
    try:
        yield connection
    finally:
        connection.close()