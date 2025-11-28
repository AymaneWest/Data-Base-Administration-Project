from fastapi import APIRouter, Depends, HTTPException

patrons=APIRouter(
    prefix="/patron",
    tags=["patron"]
)

@patrons.get("/{patron_id}")
async def fn_patron_exist(patron_id: str):
    ...


@patrons.get("/{patron_id}")
async def fn_get_active_loan_count(patron_id: str):
    ...

@patrons.get("/{patron_id}")
async def fn_patron_eligibility(patron_id: str):
    ...
@patrons.get("/{patron_id}")
async def sp_add_patron(patron_id: str):
    ...

@patrons.get("/{patron_id}")
async def sp_update_patron(patron_id: str):
    ...

@patrons.get("/{patron_id}")
async def sp_renew_membership(patron_id: str):
    ...

@patrons.get("/{patron_id}")
async def sp_reactive_patron(patron_id: str):
    ...

