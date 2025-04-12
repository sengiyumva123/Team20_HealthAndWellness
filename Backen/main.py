from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uvicorn
import os
from models import DreamLog, UserProfile
from voice_api import VoiceAssistant
from dream_chatbot import DreamBot
from soundscape import DreamSoundGenerator
import json

from health_service import HealthService


# Mount soundscapes directory
os.makedirs("soundscapes", exist_ok=True)
app.mount("/soundscapes", StaticFiles(directory="soundscapes"), name="soundscapes")

# Initialize services
voice_processor = VoiceAssistant()
dream_bot = DreamBot()
sound_gen = DreamSoundGenerator()

class DreamCreate(BaseModel):
    user_id: str
    content: str
    audio_path: Optional[str] = None
    sleep_quality: Optional[int] = None

@app.post("/api/dreams")
async def create_dream(dream: DreamCreate):
    """Main endpoint for dream logging"""
    try:
        # Process voice if available
        voice_emotion = None
        if dream.audio_path:
            voice_emotion = voice_processor.detect_emotion(dream.audio_path)
        
        # Store dream data
        dream_data = {
            **dream.dict(),
            "timestamp": datetime.now().isoformat(),
            "voice_emotion": voice_emotion
        }
        
        with open("dreams_db.json", "a") as f:
            f.write(json.dumps(dream_data) + "\n")
        
        # Generate responses
        interpretation = dream_bot.interpret(dream.content)
        soundscape_path = sound_gen.generate(dream.content)
        
        return {
            "id": str(hash(dream.timestamp)),
            "interpretation": interpretation,
            "soundscape": f"/soundscapes/{soundscape_path}"
        }
    except Exception as e:
        raise HTTPException(500, str(e))

@app.post("/api/process_audio")
async def process_audio(file: UploadFile = File(...)):
    """Process voice recordings"""
    try:
        os.makedirs("uploads", exist_ok=True)
        file_path = f"uploads/{datetime.now().timestamp()}.wav"
        
        with open(file_path, "wb") as f:
            f.write(file.file.read())
        
        return {
            "path": file_path,
            "text": voice_processor.transcribe(file_path),
            "emotion": voice_processor.detect_emotion(file_path)
        }
    except Exception as e:
        raise HTTPException(500, str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

    @app.post("/api/health/import")
async def import_health_data(data: dict):
    """Receive health data from iOS app"""
    parsed = HealthService.parse_health_data(data)
    with open(f"health_{data['user_id']}.json", "w") as f:
        json.dump(parsed, f)
    return {"status": "success"}

@app.get("/api/health/correlations/{user_id}")
async def get_health_correlations(user_id: str):
    """Get dream-health correlations"""
    try:
        with open(f"health_{user_id}.json") as f:
            health_data = json.load(f)
        with open("dreams_db.json") as f:
            dreams = [json.loads(line) for line in f if line]
        return HealthService.correlate_with_dreams(health_data, dreams)
    except FileNotFoundError:
        raise HTTPException(404, "Health data not found")
app = FastAPI(title="REMind API", version="1.0")