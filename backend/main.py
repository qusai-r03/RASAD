from contextlib import asynccontextmanager

import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI

from backend.auth.routes import router as auth_router


RASD_PROJECT_ID = "rasd-5896e"
GOV_PROJECT_ID = "rasd-government-simulation"

SERVICE_ACCOUNT_ID = (
    "firebase-adminsdk-fbsvc@rasd-5896e.iam.gserviceaccount.com"
)


def initialize_firebase():
    try:
        rasd_app = firebase_admin.get_app()
    except ValueError:
        rasd_app = firebase_admin.initialize_app(
            credentials.ApplicationDefault(),
            {
                "projectId": RASD_PROJECT_ID,
                "serviceAccountId": SERVICE_ACCOUNT_ID,
            },
        )

    try:
        government_app = firebase_admin.get_app("government")
    except ValueError:
        government_app = firebase_admin.initialize_app(
            credentials.ApplicationDefault(),
            {"projectId": GOV_PROJECT_ID},
            name="government",
        )

    return (
        firestore.client(app=rasd_app),
        firestore.client(app=government_app),
    )


@asynccontextmanager
async def lifespan(app: FastAPI):
    rasd_db, government_db = initialize_firebase()

    rasd_db.collection("citizens").limit(1).get()
    government_db.collection("gov_citizens").limit(1).get()
    government_db.collection("gov_employees").limit(1).get()

    print("RASD Firebase connected")
    print("Government Firebase connected")

    yield


app = FastAPI(
    title="RASD Authentication API",
    version="1.0.0",
    lifespan=lifespan,
)

app.include_router(auth_router)


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "RASD Backend"}