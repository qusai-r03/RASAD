from datetime import date
from pydantic import BaseModel, Field, field_validator


class LoginRequest(BaseModel):
    nationalId: str = Field(pattern=r"^[0-9]{10}$")
    password: str = Field(min_length=1)


class LoginResponse(BaseModel):
    customToken: str
    userId: str
    nationalId: str
    role: str


class CitizenRegistrationRequest(BaseModel):
    firstName: str = Field(min_length=1, max_length=100)
    lastName: str = Field(min_length=1, max_length=100)
    dateOfBirth: date
    nationalId: str = Field(pattern=r"^[0-9]{10}$")
    phoneNumber: str = Field(min_length=8, max_length=16)
    password: str = Field(min_length=8, max_length=128)
    confirmPassword: str

    @field_validator("firstName", "lastName")
    @classmethod
    def normalize_name(cls, value: str) -> str:
        return " ".join(value.strip().split())


class GovernmentVerificationResponse(BaseModel):
    verified: bool
    message: str