from fastapi import APIRouter

from backend.auth.schemas import (
    LoginRequest,
    LoginResponse,
)

from backend.auth.service import login_with_national_id


router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/login", response_model=LoginResponse)
def login(data: LoginRequest):
    return login_with_national_id(data)