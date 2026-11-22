from datetime import datetime, timezone

from fastapi import APIRouter, Header, HTTPException
from firebase_admin import auth, firestore
from google.cloud.firestore_v1.base_query import FieldFilter
from pydantic import BaseModel

from backend.auth.schemas import CitizenRegistrationRequest
from backend.auth.government_service import verify_government_citizen


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)


class CompleteCitizenRegistrationRequest(BaseModel):
    firstName: str
    lastName: str
    dateOfBirth: str
    nationalId: str
    phoneNumber: str


def national_id_already_registered(national_id: str) -> bool:
    db = firestore.client()

    for collection_name in ("citizens", "employees"):
        matches = (
            db.collection(collection_name)
            .where(
                filter=FieldFilter(
                    "nationalId",
                    "==",
                    national_id,
                )
            )
            .limit(1)
            .stream()
        )

        if next(matches, None) is not None:
            return True

    return False


@router.post("/verify-citizen")
def verify_citizen(data: CitizenRegistrationRequest):

    if data.password != data.confirmPassword:
        raise HTTPException(
            status_code=400,
            detail="Passwords do not match",
        )

    # Check existing citizen and employee accounts.
    if national_id_already_registered(data.nationalId):
        raise HTTPException(
            status_code=409,
            detail="An account already exists with this National ID",
        )

    # Verify citizen information against the government database.
    verified = verify_government_citizen(
        national_id=data.nationalId,
        first_name=data.firstName,
        last_name=data.lastName,
        date_of_birth=data.dateOfBirth.isoformat(),
    )

    if not verified:
        raise HTTPException(
            status_code=400,
            detail="Registration details could not be verified",
        )

    return {
        "verified": True,
        "message": "Government information matched",
    }


@router.post("/complete-citizen")
def complete_citizen_registration(
    data: CompleteCitizenRegistrationRequest,
    authorization: str = Header(...),
):

    # Require a Firebase ID token.
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Invalid authorization",
        )

    token = authorization.removeprefix("Bearer ").strip()

    try:
        decoded = auth.verify_id_token(
            token,
            check_revoked=True,
        )

        uid = decoded["uid"]
        firebase_user = auth.get_user(uid)

    except Exception:
        raise HTTPException(
            status_code=401,
            detail="Invalid Firebase token",
        )

    # Require recent Firebase phone authentication.
    firebase_data = decoded.get("firebase", {})

    if firebase_data.get("sign_in_provider") != "phone":
        raise HTTPException(
            status_code=403,
            detail="Phone verification required",
        )

    authentication_time = decoded.get("auth_time", 0)

    current_time = datetime.now(
        timezone.utc
    ).timestamp()

    if current_time - authentication_time > 600:
        raise HTTPException(
            status_code=403,
            detail="Recent phone verification required",
        )

    # Check that the verified phone belongs to the user.
    if firebase_user.phone_number != data.phoneNumber:
        raise HTTPException(
            status_code=403,
            detail="Verified phone number does not match",
        )

    # Validate National ID format.
    if (
        not data.nationalId.isdigit()
        or len(data.nationalId) != 10
    ):
        raise HTTPException(
            status_code=400,
            detail="Invalid National ID",
        )

    # Verify the Firebase login identifier.
    expected_email = (
        f"{data.nationalId}@rasd.invalid"
    )

    if firebase_user.email != expected_email:
        raise HTTPException(
            status_code=403,
            detail="National ID login credential not linked",
        )

    # Verify citizen identity against the government database.
    verified = verify_government_citizen(
        national_id=data.nationalId,
        first_name=data.firstName.strip(),
        last_name=data.lastName.strip(),
        date_of_birth=data.dateOfBirth,
    )

    if not verified:
        raise HTTPException(
            status_code=400,
            detail="Government identity verification failed",
        )

    db = firestore.client()

    # Check citizens and employees for duplicate National IDs.
    if national_id_already_registered(data.nationalId):
        raise HTTPException(
            status_code=409,
            detail="National ID already registered",
        )

    # Citizen document uses the Firebase Authentication UID.
    citizen_ref = (
        db.collection("citizens")
        .document(uid)
    )

    transaction = db.transaction()

    @firestore.transactional
    def save_citizen(transaction):

        existing_citizen = citizen_ref.get(
            transaction=transaction
        )

        # Prevent overwriting an existing citizen account.
        if existing_citizen.exists:
            raise HTTPException(
                status_code=409,
                detail="Citizen account already exists",
            )

        citizen_data = {
            "uid": uid,
            "nationalId": data.nationalId,
            "firstName": data.firstName.strip(),
            "lastName": data.lastName.strip(),
            "dateOfBirth": data.dateOfBirth,
            "phoneNumber": data.phoneNumber,
            "phoneVerified": True,
            "role": "citizen",
            "accountStatus": "active",
            "identityVerificationStatus": "verified",
            "createdAt": firestore.SERVER_TIMESTAMP,
        }

        # Save citizen account to Firestore.
        transaction.set(
            citizen_ref,
            citizen_data,
        )

    save_citizen(transaction)

    return {
        "success": True,
        "uid": uid,
        "role": "citizen",
        "message": "Citizen account created successfully",
    }