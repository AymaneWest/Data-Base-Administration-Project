from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
import oracledb
from dependencies.auth import require_authentication
from database.connection import get_role_based_connection, handle_oracle_error
from models.Base import BaseResponse
from pydantic import BaseModel
import logging

# Get logger for this module
logger = logging.getLogger(__name__)
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
    search: Optional[str] = Query(None),
    genre: Optional[str] = Query(None),
    material_type: Optional[str] = Query(None),
    availability: Optional[str] = Query(None),
    sort_by: Optional[str] = Query("relevance"),
    auth: dict = Depends(require_authentication)
):
    """Browse materials with optimized query performance"""
    
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            # Optimized query using subqueries instead of multiple aggregations
            query = """
                WITH MaterialCopies AS (
                    SELECT 
                        material_id,
                        COUNT(CASE WHEN copy_status = 'Available' THEN 1 END) AS available_count,
                        COUNT(CASE WHEN copy_status = 'Checked Out' THEN 1 END) AS checked_out_count,
                        COUNT(CASE WHEN copy_status = 'Reserved' THEN 1 END) AS reserved_count
                    FROM COPIES
                    GROUP BY material_id
                ),
                MaterialAuthors AS (
                    SELECT 
                        ma.material_id,
                        LISTAGG(a.first_name || ' ' || a.last_name, ', ') 
                            WITHIN GROUP (ORDER BY ma.author_sequence) AS authors
                    FROM MATERIAL_AUTHORS ma
                    JOIN AUTHORS a ON ma.author_id = a.author_id
                    GROUP BY ma.material_id
                ),
                MaterialGenres AS (
                    SELECT 
                        mg.material_id,
                        LISTAGG(g.genre_name, ', ') 
                            WITHIN GROUP (ORDER BY g.genre_name) AS genres
                    FROM MATERIAL_GENRES mg
                    JOIN GENRES g ON mg.genre_id = g.genre_id
                    GROUP BY mg.material_id
                )
                SELECT 
                    m.material_id,
                    m.title,
                    m.subtitle,
                    m.material_type,
                    m.isbn,
                    m.publication_year,
                    m.language,
                    DBMS_LOB.SUBSTR(m.description, 4000, 1) AS description,
                    m.total_copies,
                    m.available_copies,
                    m.is_reference,
                    m.is_new_release,
                    m.date_added,
                    p.publisher_name,
                    NVL(ma.authors, '') AS authors,
                    NVL(mg.genres, '') AS genres,
                    NVL(mc.available_count, 0) AS available_count,
                    NVL(mc.checked_out_count, 0) AS checked_out_count,
                    NVL(mc.reserved_count, 0) AS reserved_count,
                    CASE 
                        WHEN UPPER(m.title) LIKE UPPER(:search_param) THEN 1
                        WHEN UPPER(ma.authors) LIKE UPPER(:search_param) THEN 2
                        WHEN UPPER(m.isbn) LIKE UPPER(:search_param) THEN 3
                        ELSE 4
                    END AS relevance_score
                FROM MATERIALS m
                LEFT JOIN PUBLISHERS p ON m.publisher_id = p.publisher_id
                LEFT JOIN MaterialAuthors ma ON m.material_id = ma.material_id
                LEFT JOIN MaterialGenres mg ON m.material_id = mg.material_id
                LEFT JOIN MaterialCopies mc ON m.material_id = mc.material_id
                WHERE 1 = 1
            """

            params = {"search_param": "%%%"}  # Default for relevance calculation

            # Apply filters
            if search:
                query += """
                    AND (
                        UPPER(m.title) LIKE UPPER(:search)
                        OR UPPER(ma.authors) LIKE UPPER(:search)
                        OR UPPER(m.isbn) LIKE UPPER(:search)
                        OR UPPER(m.description) LIKE UPPER(:search)
                    )
                """
                params["search"] = f"%{search}%"
                params["search_param"] = f"%{search}%"

            if genre:
                query += " AND UPPER(mg.genres) LIKE UPPER(:genre)"
                params["genre"] = f"%{genre}%"

            if material_type:
                query += " AND UPPER(m.material_type) = UPPER(:material_type)"
                params["material_type"] = material_type

            if availability == "available":
                query += " AND NVL(mc.available_count, 0) > 0"
            elif availability == "checked-out":
                query += " AND NVL(mc.checked_out_count, 0) > 0"
            elif availability == "reserved":
                query += " AND NVL(mc.reserved_count, 0) > 0"

            # Sorting
            if sort_by == "title":
                query += " ORDER BY m.title ASC"
            elif sort_by == "author":
                query += " ORDER BY ma.authors ASC"
            elif sort_by == "newest":
                query += " ORDER BY m.date_added DESC"
            else:  # relevance
                if search:
                    query += " ORDER BY relevance_score ASC, m.date_added DESC"
                else:
                    query += " ORDER BY m.date_added DESC"

            cursor.execute(query, params)

            columns = [col[0].lower() for col in cursor.description]
            results = []

            for row in cursor.fetchall():
                material = dict(zip(columns, row))

                # Determine availability status
                if material["available_count"] > 0:
                    material["availability_status"] = "available"
                elif material["reserved_count"] > 0:
                    material["availability_status"] = "reserved"
                elif material["checked_out_count"] > 0:
                    material["availability_status"] = "checked-out"
                else:
                    material["availability_status"] = "unavailable"

                # Remove relevance_score from output
                material.pop("relevance_score", None)
                
                results.append(material)

            return results

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise


@router.get("/search/suggestions")
async def get_search_suggestions(
        q: str = Query(..., min_length=1),
        limit: int = Query(10, ge=1, le=20),
        auth: dict = Depends(require_authentication)
):
    """
    Get search suggestions/autocomplete for titles, authors, and ISBNs
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                search_term = f"%{q.lower()}%"
                
                # Get suggestions from titles, authors, and ISBNs
                query = """
                    SELECT DISTINCT
                        'title' as type,
                        m.title as suggestion,
                        m.material_id
                    FROM MATERIALS m
                    WHERE LOWER(m.title) LIKE :search
                    AND ROWNUM <= :limit
                    
                    UNION ALL
                    
                    SELECT DISTINCT
                        'author' as type,
                        a.first_name || ' ' || a.last_name as suggestion,
                        NULL as material_id
                    FROM AUTHORS a
                    JOIN MATERIAL_AUTHORS ma ON a.author_id = ma.author_id
                    WHERE LOWER(a.first_name || ' ' || a.last_name) LIKE :search
                    AND ROWNUM <= :limit
                    
                    UNION ALL
                    
                    SELECT DISTINCT
                        'isbn' as type,
                        m.isbn as suggestion,
                        m.material_id
                    FROM MATERIALS m
                    WHERE LOWER(m.isbn) LIKE :search
                    AND ROWNUM <= :limit
                """
                
                cursor.execute(query, [search_term, limit])
                
                columns = [col[0].lower() for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()[:limit]]
                
                return results

            except oracledb.DatabaseError as e:
                return handle_oracle_error(e, oracle_user)

    except HTTPException:
        raise


@router.get("/genres")
async def get_genres(
        auth: dict = Depends(require_authentication)
):
    """
    Get all available genres
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            try:
                cursor.execute("SELECT genre_id, genre_name FROM genres ORDER BY genre_name")
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

from typing import List


# ============================================================================
# RESPONSE MODELS
# ============================================================================

class Author(BaseModel):
    author_id: int
    name: str
    
class Genre(BaseModel):
    genre_id: int
    name: str
    is_primary: bool

class BranchAvailability(BaseModel):
    branch_id: int
    branch_name: str
    address: str
    phone: str
    available_copies: int
    total_copies: int
    copy_ids: List[int]  # Available copy IDs at this branch

class SimilarBook(BaseModel):
    material_id: int
    title: str
    author: str
    isbn: str
    available_copies: int

class MaterialDetailsResponse(BaseModel):
    # Basic Info
    material_id: int
    title: str
    subtitle: Optional[str]
    material_type: str
    isbn: Optional[str]
    issn: Optional[str]
    
    # Publication Info
    publication_year: Optional[int]
    publisher_name: Optional[str]
    language: Optional[str]
    edition: Optional[str]
    pages: Optional[int]
    
    # Description
    description: Optional[str]
    dewey_decimal: Optional[str]
    
    # Availability
    total_copies: int
    available_copies: int
    is_reference: bool
    is_new_release: bool
    date_added: str
    
    # Relationships
    authors: List[Author]
    genres: List[Genre]
    branch_availability: List[BranchAvailability]
    similar_books: List[SimilarBook]
    
    # Patron-specific
    patron_can_borrow: bool
    patron_can_reserve: bool
    patron_already_has_it: bool
    patron_already_reserved: bool
    current_reservations_count: int
    estimated_wait_days: Optional[int]
    
    # Popularity
    times_borrowed_last_30_days: int
    times_borrowed_all_time: int

class CheckoutRequest(BaseModel):
    copy_id: int  # Patron chooses which copy (branch)
    patron_id: int
    staff_id: Optional[int] = None  # Can be NULL for self-checkout

class CheckoutResponse(BaseModel):
    success: bool
    message: str
    loan_id: Optional[int] = None
    due_date: Optional[str] = None

class ReturnRequest(BaseModel):
    loan_id: int
    staff_id: int

class ReturnResponse(BaseModel):
    success: bool
    message: str
    fine_assessed: Optional[float] = None


# ============================================================================
# ENDPOINTS
# ============================================================================

@router.get("/{material_id}/details", response_model=MaterialDetailsResponse)
async def get_material_details(
    material_id: int,
    auth: dict = Depends(require_authentication)
):
    """
    Get complete material details including availability, 
    patron-specific info, and recommendations
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]
    patron_id = auth.get("patron_id")  # May be None if staff viewing
    logger.info(f"Patron ID from auth: {patron_id}")  # Add this
    logger.info(f"Auth dict: {auth}")
    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()

            # ================================================================
            # 1. BASIC MATERIAL INFO
            # ================================================================
            cursor.execute("""
                SELECT 
                    m.material_id,
                    m.title,
                    m.subtitle,
                    m.material_type,
                    m.isbn,
                    m.issn,
                    m.publication_year,
                    p.publisher_name,
                    m.language,
                    m.edition,
                    m.pages,
                    DBMS_LOB.SUBSTR(m.description, 4000, 1) AS description,
                    m.dewey_decimal,
                    m.total_copies,
                    m.available_copies,
                    m.is_reference,
                    m.is_new_release,
                    TO_CHAR(m.date_added, 'YYYY-MM-DD') AS date_added
                FROM MATERIALS m
                LEFT JOIN PUBLISHERS p ON m.publisher_id = p.publisher_id
                WHERE m.material_id = :material_id
            """, {"material_id": material_id})
            
            material = cursor.fetchone()
            if not material:
                raise HTTPException(status_code=404, detail="Material not found")
            
            columns = [col[0].lower() for col in cursor.description]
            material_dict = dict(zip(columns, material))

            # ================================================================
            # 2. AUTHORS
            # ================================================================
            cursor.execute("""
                SELECT 
                    a.author_id,
                    a.first_name || ' ' || a.last_name AS name
                FROM MATERIAL_AUTHORS ma
                JOIN AUTHORS a ON ma.author_id = a.author_id
                WHERE ma.material_id = :material_id
                ORDER BY ma.author_sequence
            """, {"material_id": material_id})
            
            authors = [
                {"author_id": row[0], "name": row[1]}
                for row in cursor.fetchall()
            ]

            # ================================================================
            # 3. GENRES
            # ================================================================
            cursor.execute("""
                SELECT 
                    g.genre_id,
                    g.genre_name,
                    mg.is_primary_genre
                FROM MATERIAL_GENRES mg
                JOIN GENRES g ON mg.genre_id = g.genre_id
                WHERE mg.material_id = :material_id
                ORDER BY mg.is_primary_genre DESC, g.genre_name
            """, {"material_id": material_id})
            
            genres = [
                {
                    "genre_id": row[0], 
                    "name": row[1], 
                    "is_primary": row[2] == 'Y'
                }
                for row in cursor.fetchall()
            ]

            # ================================================================
            # 4. BRANCH AVAILABILITY (with copy IDs)
            # ================================================================
            cursor.execute("""
                SELECT 
                    b.branch_id,
                    b.branch_name,
                    b.address,
                    b.phone,
                    c.copy_id,
                    c.copy_status
                FROM COPIES c
                JOIN BRANCHES b ON c.branch_id = b.branch_id
                WHERE c.material_id = :material_id
                ORDER BY b.branch_name, c.copy_status
            """, {"material_id": material_id})
            
            # Group by branch
            branch_map = {}
            for row in cursor.fetchall():
                branch_id, branch_name, address, phone, copy_id, copy_status = row
                if branch_id not in branch_map:
                    branch_map[branch_id] = {
                        "branch_id": branch_id,
                        "branch_name": branch_name,
                        "address": address,
                        "phone": phone,
                        "available_copies": 0,
                        "total_copies": 0,
                        "copy_ids": []
                    }
                branch_map[branch_id]["total_copies"] += 1
                if copy_status == 'Available':
                    branch_map[branch_id]["available_copies"] += 1
                    branch_map[branch_id]["copy_ids"].append(copy_id)
            
            branch_availability = list(branch_map.values())

            patron_can_borrow = False
            patron_can_reserve = False
            patron_already_has_it = False
            patron_already_reserved = False

            if patron_id:
                # Check if patron already has this book
                cursor.execute("""
                    SELECT COUNT(*)
                    FROM LOANS l
                    JOIN COPIES c ON l.copy_id = c.copy_id
                    WHERE c.material_id = :material_id
                    AND l.patron_id = :patron_id
                    AND l.loan_status = 'Active'
                """, {"material_id": material_id, "patron_id": patron_id})
                patron_already_has_it = cursor.fetchone()[0] > 0

                # Check if patron already reserved this
                cursor.execute("""
                    SELECT COUNT(*)
                    FROM RESERVATIONS
                    WHERE material_id = :material_id
                    AND patron_id = :patron_id
                    AND reservation_status IN ('Pending', 'Ready')
                """, {"material_id": material_id, "patron_id": patron_id})
                patron_already_reserved = cursor.fetchone()[0] > 0

                # Check patron's eligibility using PL/SQL block
                # Check patron eligibility (NEW NUMBER-based function)
                is_eligible = False
                eligibility_message = None

                try:
                    error_message = cursor.var(str)
                    result = cursor.var(int)

                    plsql_block = """
                    BEGIN
                        :result := fn_check_patron_eligibility(:patron_id, :error_message);
                    END;
                    """

                    cursor.execute(plsql_block, {
                        "patron_id": patron_id,
                        "result": result,
                        "error_message": error_message
                    })

                    is_eligible = result.getvalue() == 1
                    eligibility_message = error_message.getvalue()

                except Exception as e:
                    logger.error(f"Eligibility check failed: {str(e)}")
                    is_eligible = False
                logger.info(f"=== BUTTON LOGIC DEBUG ===")
                logger.info(f"is_eligible: {is_eligible}")
                logger.info(f"patron_already_has_it: {patron_already_has_it}")
                logger.info(f"patron_already_reserved: {patron_already_reserved}")
                logger.info(f"available_copies from dict: {material_dict['available_copies']}")
                # Determine what patron can do
                if not patron_already_has_it and not patron_already_reserved and is_eligible:
                    logger.info("✓ Passed all conditions")
                    if material_dict['available_copies'] > 0:
                        patron_can_borrow = True
                        logger.info("✓ Setting patron_can_borrow = True")
                    else:
                        patron_can_reserve = True
                        logger.info("✓ Setting patron_can_reserve = True")
                else:
                    logger.info(f"✗ Failed conditions check")
                logger.info(f"FINAL: patron_can_borrow={patron_can_borrow}, patron_can_reserve={patron_can_reserve}")
                logger.info(f"=== END DEBUG ===")


            # ================================================================
            # 6. RESERVATION QUEUE INFO
            # ================================================================
            cursor.execute("""
                SELECT COUNT(*)
                FROM RESERVATIONS
                WHERE material_id = :material_id
                  AND reservation_status = 'Pending'
            """, {"material_id": material_id})
            current_reservations_count = cursor.fetchone()[0]

            # Estimate wait time using your loan period function
            cursor.execute("""
                SELECT fn_calculate_loan_period(
                    (SELECT membership_type FROM PATRONS WHERE patron_id = :patron_id)
                ) FROM DUAL
            """, {"patron_id": patron_id or 1})  # Default to 1 if no patron
            
            avg_loan_period = cursor.fetchone()[0] if patron_id else 21
            estimated_wait_days = None
            if current_reservations_count > 0:
                estimated_wait_days = current_reservations_count * avg_loan_period

            # ================================================================
            # 7. POPULARITY STATS
            # ================================================================
            cursor.execute("""
                SELECT 
                    COUNT(CASE WHEN l.checkout_date >= SYSDATE - 30 THEN 1 END) AS last_30_days,
                    COUNT(*) AS all_time
                FROM LOANS l
                JOIN COPIES c ON l.copy_id = c.copy_id
                WHERE c.material_id = :material_id
            """, {"material_id": material_id})
            
            popularity = cursor.fetchone()
            times_borrowed_last_30_days = popularity[0] if popularity else 0
            times_borrowed_all_time = popularity[1] if popularity else 0

            # ================================================================
            # 8. SIMILAR BOOKS (same genre, different material)
            # ================================================================
            cursor.execute("""
                SELECT DISTINCT
                    m2.material_id,
                    m2.title,
                    (SELECT a.first_name || ' ' || a.last_name
                     FROM MATERIAL_AUTHORS ma
                     JOIN AUTHORS a ON ma.author_id = a.author_id
                     WHERE ma.material_id = m2.material_id
                     AND ROWNUM = 1) AS author,
                    m2.isbn,
                    m2.available_copies
                FROM MATERIALS m2
                JOIN MATERIAL_GENRES mg2 ON m2.material_id = mg2.material_id
                WHERE mg2.genre_id IN (
                    SELECT genre_id 
                    FROM MATERIAL_GENRES 
                    WHERE material_id = :material_id
                )
                AND m2.material_id != :material_id
                AND m2.available_copies > 0
                ORDER BY DBMS_RANDOM.VALUE
                FETCH FIRST 6 ROWS ONLY
            """, {"material_id": material_id})
            
            similar_books = [
                {
                    "material_id": row[0],
                    "title": row[1],
                    "author": row[2] or "Unknown",
                    "isbn": row[3],
                    "available_copies": row[4]
                }
                for row in cursor.fetchall()
            ]
            # In your endpoint, after eligibility check
            logger.info(f"Eligibility result: {is_eligible}")
            logger.info(f"Eligibility message: {eligibility_message}")
            logger.info(f"Already has it: {patron_already_has_it}")
            logger.info(f"Already reserved: {patron_already_reserved}")
            logger.info(f"Available copies: {material_dict['available_copies']}")

            # ================================================================
            # RETURN COMPLETE RESPONSE
            # ================================================================
            return MaterialDetailsResponse(
                **material_dict,
                authors=authors,
                genres=genres,
                branch_availability=branch_availability,
                similar_books=similar_books,
                patron_can_borrow=patron_can_borrow,
                patron_can_reserve=patron_can_reserve,
                patron_already_has_it=patron_already_has_it,
                patron_already_reserved=patron_already_reserved,
                current_reservations_count=current_reservations_count,
                estimated_wait_days=estimated_wait_days,
                times_borrowed_last_30_days=times_borrowed_last_30_days,
                times_borrowed_all_time=times_borrowed_all_time
            )

    except oracledb.DatabaseError as e:
        return handle_oracle_error(e, oracle_user)
    except HTTPException:
        raise


@router.post("/checkout", response_model=CheckoutResponse)
async def checkout_material(
    request: CheckoutRequest,
    auth: dict = Depends(require_authentication)
):
    """Checkout a material using sp_checkout_item"""
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]
    staff_id = request.staff_id or 1
    
    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            loan_id = cursor.var(int)
            
            try:
                cursor.callproc("sp_checkout_item", [
                    request.patron_id,
                    request.copy_id,
                    staff_id,
                    loan_id
                ])
                
                # Explicitly commit
                conn.commit()  # ADD THIS
                
                cursor.execute("""
                    SELECT TO_CHAR(due_date, 'YYYY-MM-DD')
                    FROM LOANS WHERE loan_id = :loan_id
                """, {"loan_id": loan_id.getvalue()})
                
                due_date = cursor.fetchone()[0]
                
                return CheckoutResponse(
                    success=True,
                    message="Book checked out successfully",
                    loan_id=loan_id.getvalue(),
                    due_date=due_date
                )
                
            except oracledb.DatabaseError as e:
                conn.rollback()  # ADD THIS
                error_obj, = e.args
                if error_obj.code == 20201:
                    message = "Patron not eligible for checkout"
                elif error_obj.code == 20202:
                    message = "Copy not available"
                elif error_obj.code == 20203:
                    message = "Checkout failed"
                else:
                    message = str(error_obj.message)
                
                return CheckoutResponse(success=False, message=message)
                
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Checkout error: {str(e)}")
        return CheckoutResponse(success=False, message="Checkout failed")


@router.post("/return", response_model=ReturnResponse)
async def return_material(
    request: ReturnRequest,
    auth: dict = Depends(require_authentication)
):
    """
    Return a material using sp_checkin_item procedure
    Automatically calculates and assesses overdue fines if applicable
    """
    oracle_user = auth["oracle_username"]
    oracle_pass = auth["oracle_password"]

    try:
        with get_role_based_connection(oracle_user, oracle_pass) as conn:
            cursor = conn.cursor()
            
            # Output parameter for fine
            fine_assessed = cursor.var(float)
            
            try:
                cursor.callproc("sp_checkin_item", [
                    request.loan_id,
                    request.staff_id,
                    fine_assessed
                ])
                
                fine_amount = fine_assessed.getvalue()
                
                if fine_amount and fine_amount > 0:
                    message = f"Book returned. Overdue fine of ${fine_amount:.2f} has been assessed."
                else:
                    message = "Book returned on time. No fines assessed."
                
                return ReturnResponse(
                    success=True,
                    message=message,
                    fine_assessed=fine_amount if fine_amount else 0.0
                )
                
            except oracledb.DatabaseError as e:
                error_obj, = e.args
                if error_obj.code == 20207:
                    message = "Active loan not found"
                elif error_obj.code == 20208:
                    message = "Return failed"
                else:
                    message = error_obj.message
                    
                return ReturnResponse(
                    success=False,
                    message=message
                )

    except HTTPException:
        raise