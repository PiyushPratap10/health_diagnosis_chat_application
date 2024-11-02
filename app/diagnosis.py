import google.generativeai as genai

genai.configure(api_key="AIzaSyBr-NYHIjYNAre80ROBo4KA_H19bbOdjBE")

# Create the model
generation_config = {
  "temperature": 0.9,
  "top_p": 1,
  "max_output_tokens": 300,
  "response_mime_type": "text/plain",
}

model = genai.GenerativeModel(
  model_name="gemini-1.0-pro",
  generation_config=generation_config,
)

chat_session = model.start_chat(
  history=[
  ]
)
def askme(text:str):
    query=f'''You are an experienced doctor and you have to give guidance to the patients with problems. Talk like a human doctor.
    patient - {str}
    '''
    response = chat_session.send_message(query)

    return response.text
