# database.py
import oracledb
from Configuration import settings
from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional

# Database connection pool
pool = None


async def create_pool():
    global pool
    pool = oracledb.create_pool(
        user=settings.oracle_user,
        password=settings.oracle_password,
        dsn=settings.oracle_dsn,
        min=settings.oracle_min_connections,
        max=settings.oracle_max_connections
    )
    return pool


async def close_pool():
    if pool:
        pool.close()


def get_db():
    """Dependency to get database connection from pool"""
    if not pool:
        raise HTTPException(status_code=500, detail="Database pool not initialized")

    connection = pool.acquire()
    try:
        yield connection
    finally:
        pool.release(connection)