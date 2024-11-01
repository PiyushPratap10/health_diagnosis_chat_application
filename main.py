from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.database import get_db
from app.models import User
from app.schemas import UserCreate, UserResponse, UserLogin
from pydantic import BaseModel
from typing import Optional, Dict
import bcrypt
import jwt
from datetime import datetime, timedelta

app=FastAPI()

#CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # Allows listed origins only
    allow_credentials=True,          # Allows cookies or authorization headers
    allow_methods=["*"],             # Allows all HTTP methods (GET, POST, etc.)
    allow_headers=["*"],             # Allows all headers
)
# JWT configuration
SECRET_KEY = "reality_is_not_real" 
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60  

# OAuth2 password flow dependency
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="signin")

def hash_password(password:str)->str:
    salt=bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'),salt).decode('utf-8')

def verify_password(plain_password:str,hashed_password:str)->bool:
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now() + expires_delta
    else:
        expire = datetime.now() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Dependency to get the current user from a JWT token
async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except (jwt.ExpiredSignatureError, jwt.JWTError):
        raise credentials_exception
    
    async with db.begin():
        result = await db.execute(select(User).filter_by(user_id=user_id))
        user = result.scalars().first()
    if user is None:
        raise credentials_exception
    return user

# Signup endpoint
@app.post("/users/signup", response_model=UserResponse)
async def create_user(user: UserCreate, db: AsyncSession = Depends(get_db)):
    async with db.begin():
        existing_user = await db.execute(select(User).filter_by(email=user.email))
        if existing_user.scalars().first():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email is already registered."
            )

    hashed_password = hash_password(user.password)
    user_obj = User(
        email=user.email,
        password_hash=hashed_password,
        name=user.name,
        age=user.age,
        gender=user.gender
    )
    db.add(user_obj)
    await db.commit()
    await db.refresh(user_obj)
    return user_obj

# Signin endpoint
@app.post("/users/signin", response_model=Dict[str, str])
async def login_user(user: UserLogin, db: AsyncSession = Depends(get_db)):
    async with db.begin():
        result = await db.execute(select(User).filter_by(email=user.email))
        db_user = result.scalars().first()

    if not db_user or not verify_password(user.password, db_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password."
        )

    # Create JWT token for the user
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(db_user.user_id)}, expires_delta=access_token_expires
    )

    # Return user_id along with the JWT token
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": str(db_user.user_id),  # Include user_id in the response
        "email": db_user.email
    }
