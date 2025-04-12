from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from datetime import datetime
import os
from pathlib import Path

router = APIRouter()

UPLOAD_DIR = "uploads"
SOUNDSCAPE_DIR = "soundscapes"
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(SOUNDSCAPE_DIR, exist_ok=True)

@router.post("/upload")
async def upload_audio(file: UploadFile = File(...)):
    try:
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        file_path = f"{UPLOAD_DIR}/{timestamp}-{file.filename}"
        
        with open(file_path, "wb") as f:
            f.write(file.file.read())
        
        return {"path": file_path}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{file_path}")
async def get_audio(file_path: str):
    full_path = Path(file_path)
    if not full_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(full_path)

@router.post("/generate-soundscape")
async def generate_soundscape(text: str):
    try:
        # In a real app, you would generate soundscapes here
        # This is a placeholder implementation
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        file_path = f"{SOUNDSCAPE_DIR}/{timestamp}.wav"
        
        # Create empty file for demo
        with open(file_path, "wb") as f:
            pass
        
        return {"path": file_path}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))