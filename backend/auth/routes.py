from fastapi import APIRouter

from backend.auth.schemas import LoginRequest, LoginResponse
from backend.auth.service import login_user

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/login", response_model=LoginResponse)
def login(request: LoginRequest):
    return login_user(
        username=request.username,
        password=request.password,
    )