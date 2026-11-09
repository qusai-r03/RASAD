from fastapi import HTTPException, status
from firebase_admin import auth, firestore
from pwdlib import PasswordHash

password_hash = PasswordHash.recommended()

INVALID_LOGIN = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Invalid username or password",
)


def login_user(username: str, password: str) -> dict:
    db = firestore.client()

    normalized_username = username.strip().lower()

    # Find the username in our global username index.
    username_doc = (
        db.collection("usernames")
        .document(normalized_username)
        .get()
    )

    if not username_doc.exists:
        raise INVALID_LOGIN

    username_data = username_doc.to_dict()
    uid = username_data.get("uid")
    role = username_data.get("role")

    if not isinstance(uid, str) or role not in ("citizen", "employee"):
        raise INVALID_LOGIN

    # Credentials are kept separately from public profile data.
    credentials_doc = (
        db.collection("auth_credentials")
        .document(uid)
        .get()
    )

    if not credentials_doc.exists:
        raise INVALID_LOGIN

    stored_hash = credentials_doc.to_dict().get("passwordHash")

    if not stored_hash:
        raise INVALID_LOGIN

    try:
        valid_password = password_hash.verify(password, stored_hash)
    except (ValueError, TypeError):
        raise INVALID_LOGIN

    if not valid_password:
        raise INVALID_LOGIN

    # Read the trusted profile and verify its role and status.
    collection = "citizens" if role == "citizen" else "employees"

    profile_doc = db.collection(collection).document(uid).get()

    if not profile_doc.exists:
        raise INVALID_LOGIN

    profile = profile_doc.to_dict()

    if (
        profile.get("role") != role
        or profile.get("status") != "active"
        or profile.get("username", "").strip().lower()
        != normalized_username
    ):
        raise INVALID_LOGIN

    # Verify that the Firebase Authentication account is enabled.
    try:
        firebase_user = auth.get_user(uid)
    except auth.UserNotFoundError:
        raise INVALID_LOGIN

    if firebase_user.disabled:
        raise INVALID_LOGIN

    # Role is determined by trusted backend data.
    token = auth.create_custom_token(
        uid,
        developer_claims={"role": role},
    )

    return {
        "customToken": token.decode("utf-8"),
        "userId": uid,
        "username": normalized_username,
        "role": role,
    }