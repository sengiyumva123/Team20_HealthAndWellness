# wellness_api.py
import requests
from typing import List
from config import WELLNESS_API_KEY

class WellnessAPI:
    BASE_URL = "https://api.wellnessplatform.com/v1"
    
    def __init__(self):
        self.headers = {"Authorization": f"Bearer {WELLNESS_API_KEY}"}
    
    def get_meditation_tips(self, emotion: str) -> List[str]:
        response = requests.get(
            f"{self.BASE_URL}/tips/meditation",
            params={"emotion": emotion},
            headers=self.headers
        )
        return response.json().get("tips", [])
    
    def get_sleep_recommendations(self, chronotype: str) -> List[str]:
        response = requests.get(
            f"{self.BASE_URL}/sleep/recommendations",
            params={"chronotype": chronotype},
            headers=self.headers
        )
        return response.json().get("recommendations", [])
    
    def get_daily_wellness_check(self) -> str:
        response = requests.get(
            f"{self.BASE_URL}/checkin/daily",
            headers=self.headers
        )
        return response.json().get("message", "")