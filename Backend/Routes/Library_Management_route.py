# routes/library.py
from fastapi import APIRouter, Depends, HTTPException
from database import get_db
from auth import get_current_user, require_permission
import oracledb
from Schemas.Patron_schema import AddPatronRequest, AddPatronResponse, UpdatePatronRequest, RenewMembershipRequest, RenewMembershipResponse
from Schemas.Reporting_schemas import PatronStatisticsRequest, PatronStatisticsResponse
from Schemas.Base_Schema import StatusResponse
from Schemas.Material_schemas import AddMaterialRequest, AddMaterialResponse, AddCopyRequest, AddCopyResponse
from Schemas.Reservation_schemas import PlaceReservationRequest, PlaceReservationResponse
from Schemas.Fines_schemas import PayFineRequest, PayFineResponse
from Schemas.Circulation_schemas import CheckoutItemRequest, CheckoutItemResponse, CheckinItemRequest, CheckinItemResponse, RenewLoanRequest, RenewLoanResponse


router = APIRouter(prefix="/library", tags=["library"])


# Patron Management Routes
@router.post("/patrons", response_model=AddPatronResponse)
async def add_patron(
        request: AddPatronRequest,
        user_id: int = Depends(require_permission("MANAGE_PATRONS")),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        new_patron_id = cursor.var(int)

        cursor.callproc("sp_add_patron", [
            request.card_number,
            request.first_name,
            request.last_name,
            request.email,
            request.phone,
            request.address,
            request.date_of_birth,
            request.membership_type.value,
            request.branch_id,
            new_patron_id
        ])

        return AddPatronResponse(
            success=True,
            message="Patron created successfully",
            patron_id=new_patron_id.getvalue(),
            membership_expiry=None,  # You might need to fetch this separately
            max_borrow_limit=10  # You might need to fetch this separately
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.put("/patrons/{patron_id}", response_model=StatusResponse)
async def update_patron(
        patron_id: int,
        request: UpdatePatronRequest,
        user_id: int = Depends(require_permission("MANAGE_PATRONS")),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        cursor.callproc("sp_update_patron", [
            patron_id,
            request.email,
            request.phone,
            request.address
        ])

        return StatusResponse(
            success=True,
            message="Patron updated successfully"
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


# Circulation Routes
@router.post("/checkout", response_model=CheckoutItemResponse)
async def checkout_item(
        request: CheckoutItemRequest,
        user_id: int = Depends(require_permission("PROCESS_CHECKOUT")),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        loan_id = cursor.var(int)

        cursor.callproc("sp_checkout_item", [
            request.patron_id,
            request.copy_id,
            request.staff_id,
            loan_id
        ])

        return CheckoutItemResponse(
            success=True,
            message="Item checked out successfully",
            loan_id=loan_id.getvalue(),
            due_date=None  # You might need to fetch this separately
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/checkin", response_model=CheckinItemResponse)
async def checkin_item(
        request: CheckinItemRequest,
        user_id: int = Depends(require_permission("PROCESS_CHECKIN")),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        fine_assessed = cursor.var(float)

        cursor.callproc("sp_checkin_item", [
            request.loan_id,
            request.staff_id,
            fine_assessed
        ])

        return CheckinItemResponse(
            success=True,
            message="Item checked in successfully",
            fine_assessed=fine_assessed.getvalue(),
            days_overdue=0  # You might need to calculate this
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


@router.post("/renew-loan", response_model=RenewLoanResponse)
async def renew_loan(
        request: RenewLoanRequest,
        user_id: int = Depends(get_current_user),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        new_due_date = cursor.var(oracledb.DATETIME)

        cursor.callproc("sp_renew_loan", [
            request.loan_id,
            new_due_date
        ])

        return RenewLoanResponse(
            success=True,
            message="Loan renewed successfully",
            new_due_date=new_due_date.getvalue(),
            renewal_count=0  # You might need to fetch this
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


# Material Management Routes
@router.post("/materials", response_model=AddMaterialResponse)
async def add_material(
        request: AddMaterialRequest,
        user_id: int = Depends(require_permission("MANAGE_MATERIALS")),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        new_material_id = cursor.var(int)

        cursor.callproc("sp_add_material", [
            request.title,
            request.subtitle,
            request.material_type.value,
            request.isbn,
            request.publication_year,
            request.publisher_id,
            request.language,
            request.pages,
            request.description,
            request.total_copies,
            new_material_id
        ])

        return AddMaterialResponse(
            success=True,
            message="Material added successfully",
            material_id=new_material_id.getvalue()
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


# Fine Management Routes
@router.post("/fines/pay", response_model=PayFineResponse)
async def pay_fine(
        request: PayFineRequest,
        user_id: int = Depends(require_permission("PROCESS_PAYMENTS")),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        cursor.callproc("sp_pay_fine", [
            request.fine_id,
            float(request.payment_amount),
            request.payment_method.value,
            request.staff_id
        ])

        return PayFineResponse(
            success=True,
            message="Fine payment processed successfully",
            remaining_balance=0,  # You might need to fetch this
            new_fine_status="Paid"  # You might need to fetch this
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()


# Reporting Routes
@router.get("/patrons/{patron_id}/statistics", response_model=PatronStatisticsResponse)
async def get_patron_statistics(
        patron_id: int,
        user_id: int = Depends(require_permission("VIEW_REPORTS")),
        db: oracledb.Connection = Depends(get_db)
):
    cursor = db.cursor()
    try:
        stats_text = cursor.callfunc("fn_get_patron_statistics", str, [patron_id])

        # Parse the statistics text (you might want to create a better function that returns structured data)
        return PatronStatisticsResponse(
            success=True,
            message="Statistics retrieved successfully",
            statistics_text=stats_text,
            active_loans=0,  # Parse from stats_text
            overdue_loans=0,  # Parse from stats_text
            total_fines=0,  # Parse from stats_text
            reservations=0  # Parse from stats_text
        )
    except oracledb.DatabaseError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        cursor.close()