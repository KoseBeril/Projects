from flask import Flask, request, jsonify
import requests
import io
import torch
from PIL import Image
from transformers import AutoModelForImageClassification, AutoImageProcessor

app = Flask(__name__)

# Modeli sadece ihtiyaç duyulursa belleğe yükle (Lazy Loading) -- RAM kısıtlamasından kaynaklı idare edebilmek için
model = None
processor = None

def get_model():
    global model, processor
    if model is None: # plant classification için hazır model HF 
        processor = AutoImageProcessor.from_pretrained("dima806/house-plant-image-detection")
        model = AutoModelForImageClassification.from_pretrained("dima806/house-plant-image-detection")
    return model, processor

######### Flask API Routes for backend com. between the App and the backend server #############

@app.route('/upload', methods=['POST'])
def upload_plant():
    model, processor = get_model()
    file = request.files['file']
    image = Image.open(io.BytesIO(file.read())).convert("RGB")
    inputs = processor(images=image, return_tensors="pt")

    with torch.no_grad():
        outputs = model(**inputs)
        predicted_class_idx = outputs.logits.argmax(-1).item()

    return jsonify({
        "plant_name": model.config.id2label[predicted_class_idx],
        "care_tips": "You can ask the chatbot about detailed maintenance."
    })

@app.route('/chat', methods=['POST'])
def chat():
    user_message = request.json.get('message')
    # Ollama'daki Mistral'e bağlan 
    response = requests.post("localhost adress", json={
        "model": "phi3", # phi 3.5 (3.5B param. modeli çağırıldı. -- Hardware limitations)
        "prompt": user_message,
        "stream": False
    })
    return jsonify({"reply": response.json().get('response', 'Connection error.')})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)