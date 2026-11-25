import os
import math

import cloudinary
import cloudinary.uploader

from fastapi import (
    APIRouter,
    File,
    Form,
    Depends,
    HTTPException,
    UploadFile,
)
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth, firestore


router = APIRouter(
    prefix="/reports",
    tags=["Reports"],
)

security = HTTPBearer()

MAX_IMAGE_SIZE = 5 * 1024 * 1024

ALLOWED_IMAGE_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
}


@router.post("/")
async def create_report(
    category: str = Form(...),
    description: str = Form(""),
    latitude: float = Form(...),
    longitude: float = Form(...),
    image: UploadFile = File(...),
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    # 1. Verify Firebase authentication.
    token = credentials.credentials

    try:
        decoded = auth.verify_id_token(token)
        citizen_id = decoded["uid"]

    except Exception:
        raise HTTPException(
            status_code=401,
            detail="Invalid Firebase token",
        )

    db = firestore.client()

    # 2. Verify active citizen account.
    citizen = db.collection("citizens").document(citizen_id).get()

    citizen_data = citizen.to_dict() if citizen.exists else {}

    if (
        citizen_data.get("role") != "citizen"
        or citizen_data.get("accountStatus") != "active"
    ):
        raise HTTPException(
            status_code=403,
            detail="Only active citizens can submit reports",
        )

    # 3. Validate report information.
    category = category.strip()

    if not category or len(category) > 100:
        raise HTTPException(
            status_code=400,
            detail="Invalid category",
        )

    if len(description) > 2000:
        raise HTTPException(
            status_code=400,
            detail="Description is too long",
        )

    if not (
        math.isfinite(latitude)
        and math.isfinite(longitude)
        and -90 <= latitude <= 90
        and -180 <= longitude <= 180
    ):
        raise HTTPException(
            status_code=400,
            detail="Invalid GPS coordinates",
        )

    # 4. Validate image.
    if image.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Only JPG, PNG, and WebP images are allowed",
        )

    image_data = await image.read(MAX_IMAGE_SIZE + 1)

    if not image_data:
        raise HTTPException(
            status_code=400,
            detail="Image cannot be empty",
        )

    if len(image_data) > MAX_IMAGE_SIZE:
        raise HTTPException(
            status_code=400,
            detail="Image must be smaller than 5 MB",
        )

    # 5. Check Cloudinary configuration.
    required_variables = [
        "CLOUDINARY_CLOUD_NAME",
        "CLOUDINARY_API_KEY",
        "CLOUDINARY_API_SECRET",
    ]

    if not all(os.getenv(key) for key in required_variables):
        raise HTTPException(
            status_code=503,
            detail="Cloudinary is not configured",
        )

    cloudinary.config(
        cloud_name=os.environ["CLOUDINARY_CLOUD_NAME"],
        api_key=os.environ["CLOUDINARY_API_KEY"],
        api_secret=os.environ["CLOUDINARY_API_SECRET"],
        secure=True,
    )

    # 6. Generate report ID.
    report_ref = db.collection("reports").document()

    # 7. Upload image to Cloudinary.
    try:
        uploaded = cloudinary.uploader.upload(
            image_data,
            folder="rasd/reports",
            public_id=report_ref.id,
            resource_type="image",
            overwrite=False,
        )

    except Exception:
        raise HTTPException(
            status_code=502,
            detail="Cloudinary image upload failed",
        )

    # 8. Prepare Firestore report.
    report_data = {
        "reportId": report_ref.id,
        "citizenId": citizen_id,
        "municipalityId": None,
        "category": category,
        "description": description,
        "status": "pending",
        "priority": "medium",
        "latitude": latitude,
        "longitude": longitude,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "imageUrl": uploaded["secure_url"],
    }

    # 9. Save report in Firestore.
    try:
        report_ref.set(report_data)

    except Exception:
        # Remove uploaded image if Firestore saving fails.
        try:
            cloudinary.uploader.destroy(
                uploaded["public_id"],
                resource_type="image",
            )
        except Exception:
            pass

        raise HTTPException(
            status_code=500,
            detail="Failed to save report in Firestore",
        )

    # 10. Return successful response.
    return {
        "success": True,
        "reportId": report_ref.id,
        "imageUrl": uploaded["secure_url"],
        "message": "Report submitted successfully",
    }