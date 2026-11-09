from contextlib import asynccontextmanager

import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI

from backend.auth.routes import router as auth_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    if not firebase_admin._apps:
        firebase_admin.initialize_app(
            credentials.ApplicationDefault(),
            {
                "projectId": "rasd-5896e",
                "serviceAccountId": (
                    "firebase-adminsdk-fbsvc@"
                    "rasd-5896e.iam.gserviceaccount.com"
                ),
            },
        )

    db = firestore.client()
    db.collection("citizens").limit(1).get()

    print("Firebase connected successfully")

    yield


app = FastAPI(
    title="RASD Authentication API",
    version="0.2.0",
    lifespan=lifespan,
)

app.include_router(auth_router)


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": "RASD Authentication Backend",
    }