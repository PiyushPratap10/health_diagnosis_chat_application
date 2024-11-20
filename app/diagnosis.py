from huggingface_hub import InferenceClient
import os
from dotenv import load_dotenv
load_dotenv()
client = InferenceClient(api_key=os.getenv("HF-KEY"))

def chatbot_response(user_message, conversation_history=None):
    if conversation_history is None:
        conversation_history = [
            {"role": "system", "content": "You are a professional doctor. Diagnose the problems of patients and give solution in 30 words."}
        ]

    conversation_history.append({"role": "user", "content": user_message})

    try:
        response = client.chat.completions.create(
            model="Qwen/Qwen2.5-72B-Instruct",
            messages=conversation_history,
            temperature=0.5,
            max_tokens=256,
            top_p=0.7
        )
        model_response = response.choices[0].message.content
        conversation_history.append({"role": "assistant", "content": model_response})
        
        return model_response, conversation_history

    except Exception as e:
        return f"Error: {e}", conversation_history



