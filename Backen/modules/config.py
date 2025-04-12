
import os

# API Keys
WELLNESS_API_KEY = os.getenv("WELLNESS_API_KEY", "your_default_key_here")

# App Settings
MAX_DREAM_LENGTH = 10000  # characters
MAX_AUDIO_SIZE_MB = 10
SUPPORTED_AUDIO_TYPES = ["audio/mpeg", "audio/wav", "audio/ogg"]

# Color Settings
DEFAULT_EMOTION_COLORS = {
    "JOY": "#FFD700",
    "FEAR": "#800080",
    "ANGER": "#FF0000",
    "SADNESS": "#1E90FF",
    "NEUTRAL": "#808080"
}