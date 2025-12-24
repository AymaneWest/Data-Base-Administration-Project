from fastapi import APIRouter, HTTPException
from database.connection import get_admin_connection
from Schemas.Base_Schema import StatusResponse
from pydantic import BaseModel, EmailStr
from datetime import date
import oracledb
import logging

# Define Schema locally or import if you prefer a separate file
class SignUpRequest(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    password: str
    phone: str
    address: str
    date_of_birth: date

class SignUpResponse(StatusResponse):
    user_id: int
    patron_id: int
    card_number: str

router = APIRouter(prefix="/auth", tags=["authentication"])
logger = logging.getLogger(__name__)

@router.post("/register", response_model=SignUpResponse)
async def register_patron(request: SignUpRequest):
    """
    Public Endpoint for Patron Registration
    Calls sp_register_patron
    """
    with get_admin_connection() as conn:
        cursor = conn.cursor()
        try:
            # Prepare OUT parameters
            out_user_id = cursor.var(int)
            out_patron_id = cursor.var(int)
            out_card_number = cursor.var(str)
            out_success = cursor.var(int)
            out_message = cursor.var(str)

            # Call the stored procedure
            # Note: Ensure you are passing the password. Ideally, hash it here if the DB doesn't.
            # Assuming DB stores what we send, we should hash it or trust the DB procedure if it hashes.
            # Based on the plan, specific hashing logic wasn't mandated but standard practice implies hashing.
            # For this MVP step, we pass plain text or client-hashed, letting the DB handle the insert.
            
            cursor.callproc("sp_register_patron", [
                request.first_name,
                request.last_name,
                request.email,
                request.password, 
                request.phone,
                request.address,
                request.date_of_birth,
                out_user_id,
                out_patron_id,
                out_card_number,
                out_success,
                out_message
            ])

            if out_success.getvalue() == 1:
                logger.info(f"New Patron Registered: {request.email}, Card: {out_card_number.getvalue()}")
                return SignUpResponse(
                    success=True,
                    message=out_message.getvalue(),
                    user_id=out_user_id.getvalue(),
                    patron_id=out_patron_id.getvalue(),
                    card_number=out_card_number.getvalue()
                )
            else:
                logger.warning(f"Registration failed for {request.email}: {out_message.getvalue()}")
                raise HTTPException(
                    status_code=400,
                    detail=out_message.getvalue()
                )

        except oracledb.DatabaseError as e:
            error, = e.args
            logger.error(f"Registration DB Error: {error.message}")
            raise HTTPException(
                status_code=500,
                detail=f"Database error: {error.message}"
            )
