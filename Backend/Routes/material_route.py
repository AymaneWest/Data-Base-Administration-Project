from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
import oracledb
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse
from pydantic import BaseModel

router = APIRouter(prefix="/materials", tags=["Material Management"])


# Request/Response Models
class AddCopyRequest(BaseModel):
    material_id: int
    barcode: str
    branch_id: int
    acquisition_price: float


class AddCopyResponse(BaseResponse):
    copy_id: Optional[int] = None
    material_id: Optional[int] = None


class UpdateMaterialRequest(BaseModel):
    material_id: int
    title: Optional[str] = None
    description: Optional[str] = None
    language: Optional[str] = None


class UpdateMaterialResponse(BaseResponse):
    material_id: Optional[int] = None


class DeleteMaterialRequest(BaseModel):
    material_id: int
    staff_id: int


class DeleteMaterialResponse(BaseResponse):
    material_id: Optional[int] = None


# Endpoints
@router.post("/add-copy", response_model=AddCopyResponse)
async def add_copy(
        request: AddCopyRequest,
        auth: dict = Depends(require_authentication)
):
    """Add a new copy of a material"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Create OUT parameter for new copy ID
                new_copy_id = cursor.var(int)

                cursor.callproc("sp_add_copy", [
                    request.material_id,
                    request.barcode,
                    request.branch_id,
                    request.acquisition_price,
                    new_copy_id
                ])

                return AddCopyResponse(
                    success=True,
                    message="Copy added successfully",
                    copy_id=new_copy_id.getvalue(),
                    material_id=request.material_id
                )



            except oracledb.DatabaseError as e:

                error_response = handle_oracle_error(e, oracle_user)

                return AddCopyResponse(

                    copy_id=None,

                    material_id=request.material_id,

                    **error_response  # Now this works

                )

    except HTTPException:
        raise


@router.put("/update", response_model=UpdateMaterialResponse)
async def update_material(
        request: UpdateMaterialRequest,
        auth: dict = Depends(require_authentication)
):
    """Update material information"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_update_material", [
                    request.material_id,
                    request.title,
                    request.description,
                    request.language
                ])

                return UpdateMaterialResponse(
                    success=True,
                    message="Material updated successfully",
                    material_id=request.material_id
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return UpdateMaterialResponse(
                    success=False,
                    message="Error updating material",
                    **error_response
                )

    except HTTPException:
        raise


@router.delete("/delete", response_model=DeleteMaterialResponse)
async def delete_material(
        request: DeleteMaterialRequest,
        auth: dict = Depends(require_authentication)
):
    """Delete a material"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.callproc("sp_delete_material", [
                    request.material_id,
                    request.staff_id
                ])

                return DeleteMaterialResponse(
                    success=True,
                    message="Material deleted successfully",
                    material_id=request.material_id
                )

            except oracledb.DatabaseError as e:
                error_response = handle_oracle_error(e, oracle_user)
                return DeleteMaterialResponse(
                    success=False,
                    message="Error deleting material",
                    **error_response
                )

    except HTTPException:
        raise