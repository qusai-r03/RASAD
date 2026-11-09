import re

import firebase_admin
from firebase_admin import firestore


def verify_government_citizen(
    national_id: str,
    first_name: str,
    last_name: str,
    date_of_birth: str,
) -> bool:

    if not re.fullmatch(r"[0-9]{10}", national_id):
        return False

    government_app = firebase_admin.get_app("government")
    db = firestore.client(app=government_app)

    records = (
        db.collection("gov_citizens")
        .where("nationalId", "==", national_id)
        .limit(2)
        .get()
    )

    # Reject missing or duplicate government records.
    if len(records) != 1:
        return False

    citizen = records[0].to_dict()

    def normalize(value):
        return " ".join(str(value or "").strip().casefold().split())

    return (
        normalize(citizen.get("firstName")) == normalize(first_name)
        and normalize(citizen.get("lastName")) == normalize(last_name)
        and citizen.get("dateOfBirth") == date_of_birth
    )