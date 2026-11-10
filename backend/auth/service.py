import firebase_admin

from fastapi import HTTPException
from firebase_admin import auth, firestore
from pwdlib import PasswordHash

from backend.auth.schemas import LoginRequest


password_hash = PasswordHash.recommended()


def get_rasd_db():
    rasd_app = firebase_admin.get_app()
    return firestore.client(app=rasd_app)


def login_with_national_id(data: LoginRequest):
    db = get_rasd_db()

    # Search the backend-private credentials collection.
    credentials = (
        db.collection("auth_credentials")
        .where("nationalId", "==", data.nationalId)
        .limit(2)
        .get()
    )

    if len(credentials) != 1:
        raise HTTPException(
            status_code=401,
            detail="Invalid National ID or password",
        )

    account = credentials[0].to_dict()

    stored_hash = account.get("passwordHash")
    user_id = account.get("authUid")
    role = account.get("role")

    if not stored_hash or not user_id or role not in ("citizen", "employee"):
        raise HTTPException(
            status_code=401,
            detail="Invalid National ID or password",
        )

    try:
        valid_password = password_hash.verify(
            data.password,
            stored_hash,
        )
    except Exception:
        valid_password = False

    if not valid_password:
        raise HTTPException(
            status_code=401,
            detail="Invalid National ID or password",
        )

    if account.get("status") != "active":
        raise HTTPException(
            status_code=403,
            detail="Account is not active",
        )

    # The role comes from the backend, never from the login form.
    custom_token = auth.create_custom_token(
        user_id,
        developer_claims={"role": role},
    )

    return {
        "customToken": custom_token.decode("utf-8"),
        "userId": user_id,
        "nationalId": data.nationalId,
        "role": role,
    }