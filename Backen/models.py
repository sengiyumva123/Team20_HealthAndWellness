
from pydantic import BaseModel
from typing import Literal, Optional
from datetime import time

class UserProfile(BaseModel):
    user_id: str
    chronotype: Literal["lion", "bear", "wolf", "dolphin"]
    preferred_bedtime: Optional[time] = None
    preferred_waketime: Optional[time] = None
    emotion_colors: dict = {
        "JOY": "#FFD700",
        "FEAR": "#800080",
        "ANGER": "#FF0000",
        "SADNESS": "#1E90FF",
        "NEUTRAL": "#808080"
    }
    wellness_connected: bool = False