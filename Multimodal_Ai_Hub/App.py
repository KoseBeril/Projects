import gradio as gr
from transformers import pipeline

class MultiTaskModel:
    """
    these are NLP's from Hugging Face using transformers library.(multimodal task)
    Models are lazily loaded to save RAM.
    """
    def __init__(self):
        # Dictionary to store loaded pipelines, call them inside each operation
        self.pipelines = {}

    def _get_pipeline(self, task, model_name=None, **kwargs):
        """Helper to load pipeline only once."""
        if task not in self.pipelines:
            print(f"--- Loading {task} model: {model_name} ---")
            self.pipelines[task] = pipeline(task, model=model_name, **kwargs)
        return self.pipelines[task]

    def sentiment_analysis(self, text):
        pipe = self._get_pipeline("sentiment-analysis", "distilbert/distilbert-base-uncased-finetuned-sst-2-english")
        return pipe(text)

    def zero_shot_classification(self, text, labels):
        pipe = self._get_pipeline("zero-shot-classification", "facebook/bart-large-mnli")
        # Split labels if provided as a comma-separated string
        label_list = [label.strip() for label in labels.split(",")]
        return pipe(text, label_list)

    def question_answering(self, question, context):
        pipe = self._get_pipeline("question-answering", "deepset/roberta-base-squad2")
        return pipe(question=question, context=context)

    def summarize(self, text):
        pipe = self._get_pipeline("summarization", "facebook/bart-large-cnn")
        return pipe(text, max_length=80, min_length=20)

    def generate_text(self, prompt):
        pipe = self._get_pipeline("text2text-generation", "google/flan-t5-base")
        return pipe(prompt, max_length=80)

    def translate(self, text):
        # English to Turkish conversion here 
        pipe = self._get_pipeline("translation", "Helsinki-NLP/opus-mt-en-tr")
        return pipe(text)

    def fill_mask(self, text):
        pipe = self._get_pipeline("fill-mask", "bert-base-uncased")
        return pipe(text)

    def named_entity_recognition(self, text):
        pipe = self._get_pipeline("ner", "dbmdz/bert-large-cased-finetuned-conll03-english", aggregation_strategy="simple")
        return pipe(text)

    def image_classification(self, image):
        pipe = self._get_pipeline("image-classification", "google/vit-base-patch16-224")
        return pipe(image)

    def speech_recognition(self, audio):
        pipe = self._get_pipeline("automatic-speech-recognition", "facebook/wav2vec2-large-960h")
        return pipe(audio)

# Initialize the logic engine
engine = MultiTaskModel()

# --- Gradio UI Implementation ---

def create_demo():
    with gr.Blocks(theme=gr.themes.Soft()) as demo:
        gr.Markdown("# 🚀 Multimodal AI Hub\n### Explore NLP, Vision, and Audio tasks.")

        with gr.Tab("Sentiment"):
            txt = gr.Textbox(label="Input Text")
            out = gr.JSON()
            gr.Button("Analyze").click(engine.sentiment_analysis, txt, out)

        with gr.Tab("Zero-shot"):
            txt = gr.Textbox(label="Input Text")
            lbl = gr.Textbox(label="Candidate Labels (comma separated)", placeholder="politics, sports, tech")
            out = gr.JSON()
            gr.Button("Classify").click(engine.zero_shot_classification, [txt, lbl], out)

        with gr.Tab("QA"):
            ctx = gr.Textbox(label="Context (Paragraph)")
            que = gr.Textbox(label="Question")
            out = gr.JSON()
            gr.Button("Find Answer").click(engine.question_answering, [que, ctx], out)

        with gr.Tab("Summarization"):
            txt = gr.Textbox(label="Long Text", lines=5)
            out = gr.JSON()
            gr.Button("Summarize").click(engine.summarize, txt, out)

        with gr.Tab("Text Generation"):
            txt = gr.Textbox(label="Prompt", placeholder="The future of AI is...")
            out = gr.JSON()
            gr.Button("Generate").click(engine.generate_text, txt, out)

        with gr.Tab("Translation (EN-TR)"):
            txt = gr.Textbox(label="English Text")
            out = gr.JSON()
            gr.Button("Translate").click(engine.translate, txt, out)

        with gr.Tab("Mask Filling"):
            txt = gr.Textbox(label="Text with [MASK]", placeholder="The capital of France is [MASK].")
            out = gr.JSON()
            gr.Button("Fill").click(engine.fill_mask, txt, out)

        with gr.Tab("NER"):
            txt = gr.Textbox(label="Text")
            out = gr.JSON()
            gr.Button("Extract Entities").click(engine.named_entity_recognition, txt, out)

        with gr.Tab("Image Classification"):
            img = gr.Image(type="pil", label="Upload Image")
            out = gr.JSON()
            gr.Button("Classify Image").click(engine.image_classification, img, out)

        with gr.Tab("Speech Recognition"):
            aud = gr.Audio(type="filepath", label="Upload or Record Audio")
            out = gr.JSON()
            gr.Button("Transcribe").click(engine.speech_recognition, aud, out)

    return demo

if __name__ == "__main__":
    app = create_demo()
    app.launch()