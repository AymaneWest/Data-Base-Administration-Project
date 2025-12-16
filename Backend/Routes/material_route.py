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


# ============================================================================
# NEW ENDPOINTS FOR PATRON BROWSING
# ============================================================================

@router.get("/browse")
async def browse_materials(
        search: str = None,
        auth: dict = Depends(require_authentication)
):
    """
    Browse all materials with full details for patron viewing
    Returns materials with authors, genres, and copy availability
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Build query to get materials with details
                query = """
                    SELECT DISTINCT
                        m.material_id,
                        m.title,
                        m.subtitle,
                        m.material_type,
                        m.isbn,
                        m.publication_year,
                        m.language,
                        m.description,
                        m.total_copies,
                        m.available_copies,
                        m.is_reference,
                        m.is_new_release,
                        p.publisher_name,
                        LISTAGG(DISTINCT a.full_name, ', ') WITHIN GROUP (ORDER BY ma.author_sequence) AS authors,
                        LISTAGG(DISTINCT g.genre_name, ', ') WITHIN GROUP (ORDER BY g.genre_name) AS genres
                    FROM MATERIALS m
                    LEFT JOIN PUBLISHERS p ON m.publisher_id = p.publisher_id
                    LEFT JOIN MATERIAL_AUTHORS ma ON m.material_id = ma.material_id
                    LEFT JOIN AUTHORS a ON ma.author_id = a.author_id
                    LEFT JOIN MATERIAL_GENRES mg ON m.material_id = mg.material_id
                    LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
                    WHERE 1=1
                """
                
                params = []
                
                # Add search filter if provided
                if search:
                    query += " AND (LOWER(m.title) LIKE :search OR LOWER(a.full_name) LIKE :search OR m.isbn LIKE :search)"
                    params.append(f"%{search.lower()}%")
                
                query += """
                    GROUP BY 
                        m.material_id, m.title, m.subtitle, m.material_type, m.isbn,
                        m.publication_year, m.language, m.description, m.total_copies,
                        m.available_copies, m.is_reference, m.is_new_release, p.publisher_name
                    ORDER BY m.date_added DESC
                """

                if params:
                    cursor.execute(query, [params[0]])
                else:
                    cursor.execute(query)
                
                columns = [col[0].lower() for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                
                return results

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


@router.get("/{material_id}")
async def get_material_detail(
        material_id: int,
        auth: dict = Depends(require_authentication)
):
    """
    Get detailed information for a single material
    Includes all metadata, authors, genres, and branch availability
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                # Get basic material info
                cursor.execute("""
                    SELECT 
                        m.*,
                        p.publisher_name,
                        p.country as publisher_country
                    FROM MATERIALS m
                    LEFT JOIN PUBLISHERS p ON m.publisher_id = p.publisher_id
                    WHERE m.material_id = :material_id
                """, [material_id])
                
                row = cursor.fetchone()
                if not row:
                    raise HTTPException(status_code=404, detail="Material not found")
                
                columns = [col[0].lower() for col in cursor.description]
                material = dict(zip(columns, row))

                # Get authors
                cursor.execute("""
                    SELECT a.author_id, a.full_name, ma.author_role, ma.author_sequence
                    FROM MATERIAL_AUTHORS ma
                    JOIN AUTHORS a ON ma.author_id = a.author_id
                    WHERE ma.material_id = :material_id
                    ORDER BY ma.author_sequence
                """, [material_id])
                
                authors = [dict(zip([col[0].lower() for col in cursor.description], row)) 
                          for row in cursor.fetchall()]
                material['authors'] = authors

                # Get genres
                cursor.execute("""
                    SELECT g.genre_id, g.genre_name, mg.is_primary_genre
                    FROM MATERIAL_GENRES mg
                    JOIN GENRES g ON mg.genre_id = g.genre_id
                    WHERE mg.material_id = :material_id
                    ORDER BY mg.is_primary_genre DESC, g.genre_name
                """, [material_id])
                
                genres = [dict(zip([col[0].lower() for col in cursor.description], row)) 
                         for row in cursor.fetchall()]
                material['genres'] = genres

                # Get branch availability
                cursor.execute("""
                    SELECT 
                        b.branch_id,
                        b.branch_name,
                        COUNT(c.copy_id) as total_copies,
                        SUM(CASE WHEN c.copy_status = 'Available' THEN 1 ELSE 0 END) as available_copies
                    FROM COPIES c
                    JOIN BRANCHES b ON c.branch_id = b.branch_id
                    WHERE c.material_id = :material_id
                    GROUP BY b.branch_id, b.branch_name
                    ORDER BY b.branch_name
                """, [material_id])
                
                branches = [dict(zip([col[0].lower() for col in cursor.description], row)) 
                           for row in cursor.fetchall()]
                material['branch_availability'] = branches

                return material

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise
