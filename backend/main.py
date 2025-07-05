from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import requests

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

def query_r_model(story):
    response = requests.post(
        "http://127.0.0.1:8001/predict",
        json={"text": story},
        timeout=30
    )
    response.raise_for_status()
    return response.json()

@app.post("/analyze", response_model=MotiveScores)
async def analyze_story(request: StoryRequest):
    story = request.story
    result = query_r_model(story)
    return MotiveScores(
        achievement=result["achievement"][0] if isinstance(result["achievement"], list) else result["achievement"],
        affiliation=result["affiliation"][0] if isinstance(result["affiliation"], list) else result["affiliation"],
        power=result["power"][0] if isinstance(result["power"], list) else result["power"]
    )

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "ok",
        "model": "r_server"
    } 