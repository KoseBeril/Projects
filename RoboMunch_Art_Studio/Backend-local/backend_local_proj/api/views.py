import os
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
#from huggingface_hub import login
#from transformers import pipeline
#from diffusers import StableDiffusionPipeline
from PIL import Image
#import torch
import io

#Ana chatbot ve resim oluşturma motorunun bulunduğu ve çağırıldığı kısım
class RoboMunchEngine:
    
    def __init__(self):
        from huggingface_hub import login
        self.pipelines = {}
        self.device = "cpu"  # CPU 
        
        # Hugging Face Login 
        my_token = os.getenv("HF_TOKEN")
        if my_token:
            login(token=my_token)

        print(f"--- RoboMunch Engine Initialized (CPU) ---")

    def _get_pipeline(self, task, model_name, **kwargs):
        from transformers import pipeline
        if task not in self.pipelines:
            print(f"--- Loading {task}: {model_name} ---")
            self.pipelines[task] = pipeline(
                task, 
                model=model_name, 
                device=self.device,
                token=True,
                **kwargs
            )
        return self.pipelines[task]
    
    def speech_recognition(self, audio_path):
        """
        Kendisine verilen ses dosyasının (.wav vb.) yolunu alır,
        Facebook Wav2Vec2 modelini yükler ve içindeki konuşmayı metne çevirir.
        """
        pipe = self._get_pipeline(
            "automatic-speech-recognition", 
            "facebook/wav2vec2-large-960h" # CPU için optimize edilmiş model 
        )
        
        print(f"--- Processing Audio: {audio_path} ---")
        out = pipe(audio_path)
        
        return out.get("text", "").strip()
    
    def chat_reply(self, message):
        pipe = self._get_pipeline("text-generation", "HuggingFaceTB/SmolLM2-135M-Instruct")
        
        system_prompt = (
            "You are RoboMunch, you ACT AS A PHOTO-REALISTIC ART PROMPT GENERATOR."
            "Your job is to generate concise, descriptive, and high-quality image prompts for AI generation. "
            "Focus on visual elements: subject, environment, lighting, art style, and color palette. "
            "Your ONLY output should be a detailed prompt about digital images. Don't add abstract words." # it does:( I had to add this to make it work
        )
        
        prompt = f"<|im_start|>system\n{system_prompt}<|im_end|>\n<|im_start|>user\n{message}<|im_end|>\n<|im_start|>assistant\n"
        
        out = pipe(prompt, 
                   max_new_tokens=128, 
                   do_sample=True, 
                   temperature=0.7,
                   pad_token_id=50256)
        
        response = out[0]['generated_text'].split("<|im_start|>assistant\n")[-1].replace("<|im_end|>", "").strip()
        return response

    # image generation function using Stable Diffusion
    def generate_image(self, prompt):
        import torch
        from diffusers import StableDiffusionPipeline
        if not prompt: return None
        
        if "text-to-image" not in self.pipelines:
            print("--- Loading Stable Diffusion v1-5 ---") # (This may take a while on CPU) 
            self.pipelines["text-to-image"] = StableDiffusionPipeline.from_pretrained(
                "runwayml/stable-diffusion-v1-5",
                torch_dtype=torch.float32,
                use_safetensors=True
            ).to(self.device)

        pipe = self.pipelines["text-to-image"]
        print(f"--- Generating Image for: {prompt} ---")
        
        image = pipe(prompt, num_inference_steps=15).images[0]
        return image

munch_engine = RoboMunchEngine()

# ---------------- flask-like API endpoints for chat, image generation, and speech-to-text ------------------

@api_view(['POST'])
def chat_with_munch(request):
    user_message = request.data.get('message', '')
    if not user_message:
        return Response({'reply': 'Empty messages cannot be sent.'}, status=400)
    
    try:
        bot_reply = munch_engine.chat_reply(user_message)
        return Response({'reply': bot_reply})
            
    except Exception as e:
        return Response({'reply': f"AI engine error: {str(e)}"}, status=500)


@api_view(['POST'])
def paint_image(request):
    prompt = request.data.get('prompt', '')
    if not prompt:
        return Response({'error': 'Prompt cannot be empty.'}, status=400)
        
    try:
        pil_img = munch_engine.generate_image(prompt)
        
        if pil_img:
            buffer = io.BytesIO()
            pil_img.save(buffer, format="JPEG")
            return HttpResponse(buffer.getvalue(), content_type="image/jpeg")
        else:
            return Response({'error': 'Image could not be generated.'}, status=500)
            
    except Exception as e:
        return Response({'error': f"AI engine error: {str(e)}"}, status=500)

@api_view(['POST'])
def speech_to_text_view(request):
    audio_file = request.FILES.get('audio')
    file_name = default_storage.save('temp_audio.wav', audio_file)
    file_path = default_storage.path(file_name)
    

    recognized_text = munch_engine.speech_recognition(file_path)
    

    if os.path.exists(file_path):
        os.remove(file_path)
        
    return Response({'text': recognized_text})

