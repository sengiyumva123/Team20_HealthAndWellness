import openai
import numpy as np
from scipy.io import wavfile
import subprocess

class VoiceAssistant:
    def __init__(self):
        self.whisper_model = "whisper-1"
        
    def transcribe(self, file_path: str) -> str:
        """Convert speech to text using Whisper"""
        with open(file_path, "rb") as f:
            result = openai.Audio.transcribe(self.whisper_model, f)
        return result["text"]
    
    def detect_emotion(self, file_path: str) -> str:
        """Analyze voice tone characteristics"""
        try:
            sr, data = wavfile.read(file_path)
            if data.ndim > 1:  # Convert stereo to mono
                data = data.mean(axis=1)
            
            features = {
                "pitch_var": np.std(data),
                "intensity": np.mean(np.abs(data))
            }
            
            if features["pitch_var"] > 500:
                return "anxious"
            elif features["intensity"] < 1000:
                return "calm"
            return "neutral"
        except Exception:
            return "unknown"