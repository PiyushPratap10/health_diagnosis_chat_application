# main.py
from fastapi import FastAPI, Depends, HTTPException, status, WebSocket, WebSocketDisconnect
from fastapi.security import OAuth2PasswordBearer,OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.database import get_db, mongodb
from app.models import User,UserToken
from app.schemas import UserCreate, UserResponse, UserLogin, Message, ChatSession,UserUpdate
from app.diagnosis import chatbot_response
from uuid import uuid4
from datetime import datetime, timedelta
import bcrypt
import jwt
from typing import Optional, Dict, List, Annotated
import asyncio
from sqlalchemy import delete
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

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/token")

# Password hashing functions
def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.now() + expires_delta if expires_delta else datetime.now() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Dependency to get current user
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        # Decode the JWT token
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            print("User ID not found in token payload")
            raise credentials_exception
    except (jwt.ExpiredSignatureError, jwt.JWTError) as e:
        print("Token decoding error:", str(e))
        raise credentials_exception

    # Fetch the user from the database
    async with db.begin():
        result = await db.execute(select(User).filter_by(user_id=user_id))
        user = result.scalars().first()

        if user is None:
            print("User not found in database")
            raise credentials_exception
        
        # Fetch the token from UserToken table
        token_entry = await db.execute(select(UserToken).filter_by(user_id=user.user_id))
        user_token = token_entry.scalars().first()

        # Debugging: print tokens to confirm matching
        print("Token in request:", token)
        print("Token in database:", user_token.token if user_token else "No token found in database")

        # Validate token in UserToken table
        if user_token is None or user_token.token != token:
            print("Token mismatch")
            raise credentials_exception

    return user


class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}  # Maps session_id to WebSocket connections

    async def connect(self, websocket: WebSocket, session_id: str):
        await websocket.accept()
        self.active_connections[session_id] = websocket

    def disconnect(self, session_id: str):
        self.active_connections.pop(session_id, None)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

manager = ConnectionManager()

# In-Memory Chat Storage
chat_memory: Dict[str, List[Dict]] = {}  # Stores messages temporarily by session_id

@app.websocket("/ws/chat/{user_id}/{session_id}")
async def websocket_chat(websocket: WebSocket, user_id: str, session_id: str):
    # Connect to the WebSocket and initialize session memory if needed
    await manager.connect(websocket, session_id)
    
    if session_id not in chat_memory:
        chat_memory[session_id] = []
    
    try:
        chat_history=[{"role": "system", "content": "You are a professional doctor. Diagnose the problems of patients and give solution in 30 words."}]
        while True:
            # Receive message from user
            data = await websocket.receive_text()

            # Generate model response using chatbot_response function
            model_response, chat_history = chatbot_response(data,chat_history)
            
            # Store the message pair (user and model response) in chat_memory
            message_pair = {
                "user_message": {
                    "message": data,
                    "sender": "user",
                    "timestamp": datetime.now()
                },
                "model_response": {
                    "message": model_response,
                    "sender": "model",
                    "timestamp": datetime.now()
                }
            }
            chat_memory[session_id].append(message_pair)

            # Send the model response back to the client
            await manager.send_personal_message(model_response, websocket)

            # Periodic save to MongoDB after every 5 messages
            if len(chat_memory[session_id]) >= 5:
                await save_chat_to_mongo(user_id, session_id)

    except WebSocketDisconnect:
        # On disconnection, save remaining messages and cleanup
        await save_chat_to_mongo(user_id, session_id)
        chat_memory.pop(session_id, None)
        manager.disconnect(session_id)

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
    return {
        "user_id":user_obj.user_id,
        "email":user_obj.email,
        "name":user_obj.name,
        "password":user_obj.password_hash,
        "age":user_obj.age,
        "gender":user_obj.gender
    }

# Signin Endpoint
@app.post("/users/signin")
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
        data={"sub": str(db_user.email)}, expires_delta=access_token_expires
    )

    # Update or insert token into UserToken table
    async with db.begin():
        token_entry = await db.execute(select(UserToken).filter_by(user_id=db_user.user_id))
        user_token = token_entry.scalars().first()
        
        if user_token:
            user_token.token = access_token
        else:
            user_token = UserToken(user_id=db_user.user_id, token=access_token)
            db.add(user_token)
        
        await db.commit()

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": str(db_user.user_id),
        "email": db_user.email,
        "name":db_user.name,
        "password":db_user.password_hash,
        "age":db_user.age,
        "gender":db_user.gender
    }

@app.post("/users/token/{user_id}")
async def get_token(user_id:str,db:AsyncSession=Depends(get_db)):
    async with db.begin():
        result = await db.execute(select(UserToken).filter_by(user_id=user_id))
        user_token = result.scalars().first()

        if user_token:
            return{'token':user_token.token}
        else:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="User token not available")
        


@app.post("/users/profile/{user_id}")
async def get_profile(user_id:str,db:AsyncSession=Depends(get_db)):
    async with db.begin():
        result=await db.execute(select(User).filter_by(user_id=user_id))
        db_user=result.scalars().first()
        if not db_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found."
            )
    return {
        "email": db_user.email,
        "name": db_user.name,
        "gender": db_user.gender,
        "age": db_user.age,
        "user_id": db_user.user_id
    }

@app.put("/users/update/{user_id}")
async def update_user(user_id: str, user: UserUpdate, db: AsyncSession = Depends(get_db)):
    
    async with db.begin():
        result = await db.execute(select(User).filter_by(user_id=user_id))
        db_user=result.scalars().first()

        if not db_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
    
        update_data=user.model_dump(exclude_unset=True)
        for key,value in update_data.items():
            setattr(db_user,key,value)

   
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)

    return {
        "email": db_user.email,
        "name": db_user.name,
        "gender": db_user.gender,
        "age": db_user.age,
        "user_id": db_user.user_id
    }

async def authenticate_user(username:str,password:str,db:AsyncSession):
    async with db.begin():
        result= await db.execute(select(User).filter_by(email=username))
        db_user=result.scalars().first()
        if not db_user:
            return False
        if not verify_password(password,db_user.password_hash):
            return False
    return db_user

@app.post("/token")
async def login_for_access_token(form:Annotated[OAuth2PasswordRequestForm, Depends()],db:AsyncSession=Depends(get_db)):
    user =await authenticate_user(form.username,form.password,db)
    if not user:
        raise HTTPException()
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(form.username)}, expires_delta=access_token_expires
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
    }
    
@app.get("/")
async def get_user(user:dict = Depends(get_current_user),db:AsyncSession=Depends(get_db)):
    if user is None:
        return HTTPException()
    return user


@app.delete("/users/delete/{user_id}",status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id:str,db:AsyncSession=Depends(get_db)):
    async with db.begin():
        result=await db.execute(select(User).filter_by(user_id=user_id))
        db_user=result.scalars().first()

        if not db_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        await db.execute(delete(UserToken).where(UserToken.user_id==user_id))
        await db.delete(db_user)

    chat_collection=mongodb['user_chats']
    deletion_result=await chat_collection.delete_many({"user_id":user_id})

    return {"message":"User and associated data successfully deleted"}

