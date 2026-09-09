'''For sentiment Analysis'''
from transformers import pipeline

classifier = pipeline(
    "sentiment-analysis",
    model="distilbert/distilbert-base-uncased-finetuned-sst-2-english"
)

result = classifier("I hate EE471 course")

print(result)

result = classifier("I've been waiting for a Embedded systems course my whole life")

print(result)

#'''Zero-Shot Classification'''


classifier = pipeline(
    "zero-shot-classification",
    model="facebook/bart-large-mnli"
)

text = "Berkshire keeps their cash reserves at an extremely high level."

candidate_labels = ["finance", "technology", "sports", "education"]

result = classifier(
    text,
    candidate_labels=candidate_labels
)

print(result)

#'''Text Genereator'''

generator = pipeline(
    "text2text-generation",
    model="facebook/bart-large-cnn"
)

prompt = "If I continue to successfully complete all in-class exercises in EE471 course,"

generated = generator(
    prompt,
    max_length=35,
    num_return_sequences=2
)

print("\nGenerated Sentences:")

for i, sentence in enumerate(generated):
    print(f"\nAlternative {i+1}:")
    print(sentence["generated_text"])



#'''Fill-Mask'''
unmasker = pipeline(
    "fill-mask",
    model="bert-base-uncased"
)

masked_text = "To understand generative AI, one must study [MASK] well."

predictions = unmasker(masked_text)

print("\nFill-Mask Predictions:")

for pred in predictions[:5]:
    print(pred["token_str"], "-", pred["score"])


#'''Entity recognition'''

ner = pipeline(
    "ner",
    model="dbmdz/bert-large-cased-finetuned-conll03-english",
    aggregation_strategy="simple"
)

text = "I am Nate, a research assistant in Izmir Institute of Technology, and currently living and working in beautiful city İzmir in Türkiye."

result = ner(text)

for entity in result:
    print(entity["entity_group"], ":", entity["word"])


#'''Validation with Questioning'''

qa = pipeline(
    "question-answering",
    model="distilbert-base-cased-distilled-squad"
)

text = "I am Nate, a research assistant in Izmir Institute of Technology, and currently living and working in beautiful city İzmir in Türkiye."

result = qa(
    question="Where does Nate live?",
    context=text
)

print(result)

# SUMMARIZATION

summarizer = pipeline(
    "summarization",
    model="facebook/bart-large-cnn"
)

text = """
The 2008 Global Financial Crisis stands as the most severe economic collapse 
of the 21st century, often compared to the Great Depression of the 1930s. 
Triggered by the bursting of the United States housing bubble, its effects 
rippled across the globe, leading to the collapse of major financial institutions 
and a deep international recession. The crisis began with the subprime mortgage market. 
In the early 2000s, low interest rates and a push for homeownership led banks 
to issue high-risk loans to borrowers with poor credit.
"""

summary = summarizer(
    text,
    max_length=50,
    min_length=20,
    do_sample=False
)

result = summarizer(
    "summarize: The 2008 Global Financial Crisis stands as..."
)

print(result)

# TRANSLATION
# English -> Turkish

translator = pipeline(
    "translation_en_to_tr",
    model="Helsinki-NLP/opus-mt-tc-big-en-tr"
)

text = "The 2008 Global Financial Crisis stands as the most severe economic collapse of the 21st century."

print(translator(text)[0]["translation_text"])


#'''Image Classification'''

from transformers import pipeline
from PIL import Image
import requests

classifier = pipeline(
    "image-classification",
    model="google/vit-base-patch16-224"
)

# örnek bir internet görseli
url = "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/cats.png"
image = Image.open(requests.get(url, stream=True).raw)

result = classifier(image)

print(result)

from transformers import pipeline

asr = pipeline(
    "automatic-speech-recognition",
    model="openai/whisper-large-v3"
)

url = "https://huggingface.co/datasets/Narsil/asr_dummy/resolve/main/1.flac"

result = asr(url)

print(result["text"])

#The output will be:
# He hoped there would be stew for dinner, turnips and carrots and bruised potatoes and fat mutton pieces 
# to be ladled out in thick, peppered, flour-fattened sauce.