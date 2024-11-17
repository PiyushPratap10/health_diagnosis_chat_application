import google.generativeai as genai
import base64

genai.configure(api_key="AIzaSyBr-NYHIjYNAre80ROBo4KA_H19bbOdjBE")
model = genai.GenerativeModel("gemini-1.5-pro")

sample_prompt = """You are a medical practitioner and an expert in analyzing medical-related images working for a very reputed hospital. You will be provided with images, and you need to identify the anomalies, any disease, or health issues. You need to generate the result in a detailed manner. Write all the findings, next steps, recommendation, etc. You only need to respond if the image is related to a human body and health issues. You must answer but also write a disclaimer saying "Consult with a Doctor before making any decisions".

Remember, if certain aspects are not clear from the image, it's okay to state 'Unable to determine based on the provided image.'

Now analyze the image and answer the above questions in the same structured manner defined above."""


def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')


def call_gemini_model_for_analysis(filename, sample_prompt=sample_prompt):
    base64_image = encode_image(filename)
    prompt_with_image = f"{sample_prompt}\nImage: data:image/jpeg;base64,{base64_image}"

    response = model.generate_content(prompt_with_image)
    return response.text