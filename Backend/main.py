from fastapi import Depends, FastAPI
from .Routes.Auth_route import
from .Routes.loan_route import
from .Routes.users_route import users
from .Routes.fines_route import
from .Routes.reporting_route import
from .Routes.patrons_route import patrons
from .Routes.material_route import
from .Routes.circulation_route import
from .Routes.reservation_route import


app= FastAPI()

app.include_router()
app.include_router()
app.include_router()
app.include_router()
app.include_router()
app.include_router()
app.include_router()
app.include_router()
app.include_router()