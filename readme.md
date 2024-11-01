# This is the backend of the Health Diagnosis Chat Application
 This application is designed for real-time conversation with a Health Chatbot.

 Install the packages mentioned in the requirements.txt file.

 For time being PostgreSQL should be installed on your device to use this. 
If you have it installed then make a database - health_diagnosis_app
 Then run the below code in the Query tool of Postgres
 ```sql
 CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
 CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    name VARCHAR,
    age INTEGER,
    gender VARCHAR,
    is_verified BOOLEAN DEFAULT FALSE
    );

