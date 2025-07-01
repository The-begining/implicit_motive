from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import requests
import os

app = FastAPI()

# Allow CORS for local frontend development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class StoryRequest(BaseModel):
    story: str

class MotiveScores(BaseModel):
    achievement: float
    affiliation: float
    power: float

# Hugging Face API token (set this as an environment variable for security)
HF_API_TOKEN = os.getenv("HF_API_TOKEN", "YOUR_HF_API_TOKEN")
HEADERS = {"Authorization": f"Bearer {HF_API_TOKEN}"}

MODEL_URLS = {
    "achievement": "https://api-inference.huggingface.co/models/theharmonylab/implicit-motives-achievement-roberta-large",
    "affiliation": "https://api-inference.huggingface.co/models/theharmonylab/implicit-motives-affiliation-roberta-large",
    "power": "https://api-inference.huggingface.co/models/theharmonylab/implicit-motives-power-roberta-large",
}

def query_hf(model_url, story):
    response = requests.post(model_url, headers=HEADERS, json={"inputs": story})
    response.raise_for_status()
    result = response.json()
    # Expecting a list of dicts with 'score' and 'label'
    # Find the score for the positive class (label may be 'LABEL_1' or similar)
    if isinstance(result, list) and len(result) > 0:
        # If the model returns multiple labels, pick the one with the highest score
        return max(result, key=lambda x: x.get("score", 0)).get("score", 0)
    return 0

@app.post("/analyze", response_model=MotiveScores)
async def analyze_story(request: StoryRequest):
    story = request.story
    # Query each model via Hugging Face Inference API
    achievement_score = query_hf(MODEL_URLS["achievement"], story) * 100
    affiliation_score = query_hf(MODEL_URLS["affiliation"], story) * 100
    power_score = query_hf(MODEL_URLS["power"], story) * 100

    # Normalize to sum to 100%
    total = achievement_score + affiliation_score + power_score
    if total > 0:
        achievement_pct = achievement_score / total * 100
        affiliation_pct = affiliation_score / total * 100
        power_pct = power_score / total * 100
    else:
        achievement_pct = affiliation_pct = power_pct = 0.0

    return MotiveScores(
        achievement=round(achievement_pct, 2),
        affiliation=round(affiliation_pct, 2),
        power=round(power_pct, 2)
    ) 