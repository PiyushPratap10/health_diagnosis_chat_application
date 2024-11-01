from sqlalchemy import Column, String, Boolean, UUID, Integer
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
import uuid
from app.database import Base

class User(Base):
    __tablename__ = 'users'

    user_id=Column(PG_UUID(as_uuid=True), primary_key=True,default=uuid.uuid4)
    email=Column(String, unique=True, index=True,nullable=False)
    password_hash=Column(String,nullable=False)
    name=Column(String,nullable=True)
    age=Column(Integer,nullable=True)
    gender=Column(String,nullable=True)
    is_verified=Column(Boolean,default=False)