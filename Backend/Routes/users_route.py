from fastapi import APIRouter, Depends, HTTPException

users=APIRouter(
    prefix="/user",
    tags=["user"]
)

@users.get("/{user_id}")
async def fn_has_permission(user_id: str):
    ...

@users.get("/{user_id}")
async def fn_get_user_role(user_id: str):
    ...

@users.get("/{user_id}")
async def fn_is_user_active(user_id: str):
    ...
@users.get("/{user_id}")
async def fn_is_account_locked(user_id: str):
    ...

@users.get("/{user_id}")
async def fn_is_account_locked(user_id: str):
    ...
