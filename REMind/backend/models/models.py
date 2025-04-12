from sqlalchemy import Column, String, DateTime, Integer, JSON
from database import Base

class Emotion(Base):
    __tablename__ = "emotions"
    
    id = Column(String, primary_key=True, index=True)
    dream_id = Column(String, index=True)
    label = Column(String)
    score = Column(Integer)

class Dream(Base):
    __tablename__ = "dreams"
    
    id = Column(String, primary_key=True, index=True)
    text = Column(String)
    timestamp = Column(DateTime)
    emotions = Column(JSON)  # Storing as JSON for simplicity
    archetypes = Column(JSON)
    sleep_quality = Column(Integer)
    soundscape_url = Column(String)
    voice_memo_url = Column(String)