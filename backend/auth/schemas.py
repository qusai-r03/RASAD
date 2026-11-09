from pydantic import BaseModel, Field


class LoginRequest(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    password: str = Field(min_length=1)


class LoginResponse(BaseModel):
    customToken: str
    userId: str
    username: str
    role: str