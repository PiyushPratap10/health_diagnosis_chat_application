from sqlalchemy import create_engine
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker,declarative_base
import os
from motor.motor_asyncio import AsyncIOMotorClient

DATABASE_URL="postgresql+asyncpg://postgres:887700@localhost/health_diagnosis_app"
MONGODB_URL="mongodb://localhost:27017"

# For PostgreSQL
engine=create_async_engine(DATABASE_URL)
SessionLocal=sessionmaker(bind=engine,class_=AsyncSession,expire_on_commit=False)
Base= declarative_base()

async def get_db():
    async with SessionLocal() as session:
        yield session

# For MongoDb
mongo_client=AsyncIOMotorClient(MONGODB_URL)
mongodb=mongo_client["health_diagnosis_app"]

