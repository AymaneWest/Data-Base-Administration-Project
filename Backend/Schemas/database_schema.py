from pydantic import BaseModel, Field, validator, condecimal
from typing import Optional, List, Dict, Any
from datetime import date, datetime

class OracleDBResult(BaseModel):
    success: bool
    data: Optional[Any] = None
    message: Optional[str] = None
    error: Optional[str] = None

class FunctionCallResult(BaseModel):
    return_value: Optional[Any] = None
    out_params: Optional[Dict[str, Any]] = None
    success: bool
    message: str