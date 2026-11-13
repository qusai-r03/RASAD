from fastapi import APIRouter

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)

# Login is handled directly by Firebase Authentication in Flutter.
# Government identity verification endpoints will be added here later.