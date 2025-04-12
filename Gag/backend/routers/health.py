from fastapi import APIRouter, HTTPException
from typing import List
from datetime import datetime, timedelta
from models.schemas import HealthData

router = APIRouter()

@router.get("/", response_model=List[HealthData])
def get_health_data(days: int = 7):
    try:
        # In a real app, you would fetch from HealthKit or similar
        # This is sample data for demo
        data = []
        for i in range(days):
            date = datetime.now() - timedelta(days=i)
            data.append(HealthData(
                date=date,
                sleep_hours=7.5 - (i * 0.3),
                heart_rate=65 + (i * 2),
                hrv=45 - (i * 1.5)
            ))
        return sorted(data, key=lambda x: x.date)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))