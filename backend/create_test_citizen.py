
import getpass
import re

import firebase_admin
from firebase_admin import auth, credentials, firestore

NATIONAL_ID = "1234567890"

RASD_PROJECT = "rasd-5896e"
GOV_PROJECT = "rasd-government-simulation"

SERVICE_ACCOUNT_ID = (
    "firebase-adminsdk-fbsvc@rasd-5896e.iam.gserviceaccount.com"
)

# Connect to the RASD application.
rasd_app = firebase_admin.initialize_app(
    credentials.ApplicationDefault(),
    {
        "projectId": RASD_PROJECT,
        "serviceAccountId": SERVICE_ACCOUNT_ID,
    },
)

# Connect to the government simulation.
gov_app = firebase_admin.initialize_app(
    credentials.ApplicationDefault(),
    {"projectId": GOV_PROJECT},
    name="government",
)

rasd_db = firestore.client(app=rasd_app)
gov_db = firestore.client(app=gov_app)
import os

print("\n========== FIRESTORE DIAGNOSTICS ==========")

print(
    "FIRESTORE_EMULATOR_HOST:",
    os.environ.get("FIRESTORE_EMULATOR_HOST"),
)

print("Government project:", gov_app.project_id)
print("Government database:", gov_db._database_string)

print("\nGovernment collections:")

collections = list(gov_db.collections())

print("Total collections:", len(collections))

for collection in collections:
    print("Collection:", collection.id)

print("\n==========================================\n")
for doc in gov_db.collection("gov_citizens").stream():
    data = doc.to_dict()
    print(
        "Document:", doc.id,
        "| National ID:", repr(data.get("nationalId")),
        "| Type:", type(data.get("nationalId")).__name__,
    )

# Check the fictional government citizen.
records = list(
    gov_db.collection("gov_citizens")
    .where("nationalId", "==", NATIONAL_ID)
    .limit(2)
    .stream()
)

if len(records) != 1:
    raise RuntimeError(
        "Government citizen record missing or duplicated."
    )

person = records[0].to_dict()

if (
    person.get("firstName") != "Ahmad"
    or person.get("lastName") != "Kilani"
    or person.get("dateOfBirth") != "2000-05-22"
):
    raise RuntimeError("Government citizen details do not match.")

# Keep national IDs as strings.
if not re.fullmatch(r"[0-9]{10}", NATIONAL_ID):
    raise RuntimeError("Invalid national ID.")

# Internal identifier used only by Firebase Authentication.
email = f"{NATIONAL_ID}@rasd.invalid"

# This is a development fixture, not a real registered citizen.
password = getpass.getpass("Enter a test password: ")

if len(password) < 8:
    raise RuntimeError("Password must have at least 8 characters.")

# Prevent accidental duplicate test accounts.
try:
    existing = auth.get_user_by_email(email, app=rasd_app)
except auth.UserNotFoundError:
    existing = None

if existing is not None:
    raise RuntimeError(
        f"Test account already exists with UID {existing.uid}. "
        "No existing account was modified."
    )

# Firebase Authentication stores the password securely.
user = auth.create_user(
    email=email,
    password=password,
    email_verified=False,
    disabled=False,
    app=rasd_app,
)

try:
    # Use Firebase Authentication UID as the document ID.
    profile_ref = rasd_db.collection("citizens").document(user.uid)

    profile_ref.create({
        "nationalId": NATIONAL_ID,
        "firstName": person["firstName"],
        "lastName": person["lastName"],
        "dateOfBirth": person["dateOfBirth"],
        "phoneNumber": "",
        "phoneVerified": False,
        "role": "citizen",
        "accountStatus": "active",
        "isTestAccount": True,
        "createdAt": firestore.SERVER_TIMESTAMP,
    })
except Exception:
    # Avoid leaving an orphaned Authentication user.
    auth.delete_user(user.uid, app=rasd_app)
    raise

print("SUCCESS: Development test account created.")
print("Firebase UID:", user.uid)
print("National ID:", NATIONAL_ID)
print("Role: citizen")
print("Phone verification: NOT completed")
