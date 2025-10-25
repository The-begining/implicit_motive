from fastapi import FastAPI, HTTPException
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
    # Sentences
    sentences: list
    
    # Dynamic motive results (will contain all available motives)
    # power: dict
    # achievement: dict
    # affiliation: dict
    
    # Summary statistics
    total_words: int
    total_sentences: int
    text_length_chars: int

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
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    # Handle case where R server returns lists instead of single values
    def extract_value(value):
        if isinstance(value, list):
            return value[0] if len(value) > 0 else 0
        return value
    
    # Create response with dynamic motive results
    response_data = {
        "sentences": result["sentences"],
        "total_words": extract_value(result["total_words"]),
        "total_sentences": extract_value(result["total_sentences"]),
        "text_length_chars": extract_value(result["text_length_chars"])
    }
    
    # Add all motive results dynamically
    for motive_name in ["power", "achievement", "affiliation"]:
        if motive_name in result:
            response_data[motive_name] = result[motive_name]
    
    return response_data

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "ok",
        "model": "r_server"
    }

@app.get("/models")
async def get_models():
    """Get available models from R server"""
    try:
        response = requests.get("http://127.0.0.1:8001/models", timeout=10)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching models: {str(e)}") 