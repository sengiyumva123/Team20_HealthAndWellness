from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel

class Emotion(BaseModel):
    label: str
    score: float

class DreamBase(BaseModel):
    text: str
    timestamp: Optional[datetime] = None
    emotions: List[Emotion] = []
    archetypes: List[str] = []
    sleep_quality: Optional[int] = None

class DreamCreate(DreamBase):
    pass

class Dream(DreamBase):
    id: str
    soundscape_url: Optional[str] = None
    voice_memo_url: Optional[str] = None

    class Config:
        orm_mode = True

class HealthData(BaseModel):
    date: datetime
    sleep_hours: float
    heart_rate: Optional[float] = None
    hrv: Optional[float] = None