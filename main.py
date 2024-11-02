# main.py
from fastapi import FastAPI, Depends, HTTPException, status, WebSocket, WebSocketDisconnect
from fastapi.security import OAuth2PasswordBearer
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.database import get_db, mongodb
from app.models import User
from app.schemas import UserCreate, UserResponse, UserLogin, Message, ChatSession
from app.diagnosis import askme
from uuid import uuid4
from datetime import datetime, timedelta
import bcrypt
import jwt
from typing import Optional, Dict, List
import asyncio

app = FastAPI()

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# JWT Configuration
SECRET_KEY = "reality_is_not_real" 
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 90  

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="signin")

# Password hashing functions
def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta if expires_delta else datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Dependency to get current user
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

# In-Memory Chat Storage
chat_memory: Dict[str, List[Dict]] = {}  # Stores messages temporarily by session_id

@app.websocket("/ws/chat/{user_id}/{session_id}")
async def websocket_chat(websocket: WebSocket, user_id: str, session_id: str):
    await websocket.accept()

    # Initialize session in chat_memory if it doesn't exist
    if session_id not in chat_memory:
        chat_memory[session_id] = []

    try:
        while True:
            # Receive user message
            data = await websocket.receive_text()

            # Generate model response using the `askme` function
            model_response = askme(data)

            # Store the message pair (user and model response) in chat_memory
            message_pair = {
                "user_message": {
                    "message": data,
                    "sender": "user",
                    "timestamp": datetime.utcnow()
                },
                "model_response": {
                    "message": model_response,
                    "sender": "model",
                    "timestamp": datetime.utcnow()
                }
            }
            chat_memory[session_id].append(message_pair)

            # Send the model response back to the client
            await websocket.send_text(model_response)

            # Save messages periodically
            if len(chat_memory[session_id]) >= 5:
                await save_chat_to_mongo(user_id, session_id)
    except WebSocketDisconnect:
        # On disconnection, save remaining messages
        await save_chat_to_mongo(user_id, session_id)
        chat_memory.pop(session_id, None)

# Save chat messages to MongoDB
async def save_chat_to_mongo(user_id: str, session_id: str):
    chat_collection = mongodb["user_chats"]
    session_data = chat_memory.get(session_id, [])

    # Update the session document with new messages
    await chat_collection.update_one(
        {"user_id": user_id, "session_id": session_id},
        {"$push": {"messages": {"$each": session_data}}},
        upsert=True
    )

    # Clear in-memory storage for the session
    chat_memory[session_id] = []

# Signup Endpoint
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

# Signin Endpoint
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

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(db_user.user_id)}, expires_delta=access_token_expires
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": str(db_user.user_id),
        "email": db_user.email
    }
