import whisper
from fastapi import UploadFile
from typing import Optional

class AudioTranscriber:
    def __init__(self):
        self.model = whisper.load_model("base")
    
    async def transcribe_audio(self, audio_file: UploadFile) -> Optional[str]:
        try:
            # Save temporary audio file
            with open("temp_audio.mp3", "wb") as buffer:
                buffer.write(await audio_file.read())
            
            # Transcribe
            result = self.model.transcribe("temp_audio.mp3")
            return result["text"]
        except Exception as e:
            print(f"Transcription error: {e}")
            return None