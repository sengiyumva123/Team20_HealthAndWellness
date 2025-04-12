from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
import uuid

from database import SessionLocal
from routers.schemas import Dream, DreamCreate
import models.models as models

router = APIRouter()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=Dream)
def create_dream(dream: DreamCreate, db: Session = Depends(get_db)):
    db_dream = models.Dream(
        id=str(uuid.uuid4()),
        text=dream.text,
        timestamp=dream.timestamp or datetime.now(),
        emotions=[models.Emotion(**e.dict()) for e in dream.emotions],
        archetypes=dream.archetypes,
        sleep_quality=dream.sleep_quality
    )
    db.add(db_dream)
    db.commit()
    db.refresh(db_dream)
    return db_dream

@router.get("/", response_model=List[Dream])
def read_dreams(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    dreams = db.query(models.Dream).offset(skip).limit(limit).all()
    return dreams

@router.get("/{dream_id}", response_model=Dream)
def read_dream(dream_id: str, db: Session = Depends(get_db)):
    dream = db.query(models.Dream).filter(models.Dream.id == dream_id).first()
    if dream is None:
        raise HTTPException(status_code=404, detail="Dream not found")
    return dream

@router.delete("/{dream_id}")
def delete_dream(dream_id: str, db: Session = Depends(get_db)):
    dream = db.query(models.Dream).filter(models.Dream.id == dream_id).first()
    if dream is None:
        raise HTTPException(status_code=404, detail="Dream not found")
    db.delete(dream)
    db.commit()
    return {"message": "Dream deleted"}
