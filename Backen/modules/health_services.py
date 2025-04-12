from typing import Dict, Optional
import datetime

class HealthService:
    @staticmethod
    def parse_health_data(health_data: Dict) -> Dict:
        """Transform Apple Health data into our schema"""
        return {
            "sleep_analysis": {
                "asleep": health_data.get("HKCategoryValueSleepAnalysisAsleep"),
                "in_bed": health_data.get("HKCategoryValueSleepAnalysisInBed"),
                "duration": health_data.get("duration", 0)
            },
            "heart_rate": health_data.get("heartRate", []),
            "hrv": health_data.get("hrv", [])
        }

    @staticmethod
    def correlate_with_dreams(health_data: Dict, dreams: list) -> Dict:
        """Match health metrics with dream logs"""
        correlations = []
        
        for dream in dreams:
            dream_time = datetime.datetime.fromisoformat(dream["timestamp"])
            relevant_health = {
                "hrv": HealthService._find_closest_value(
                    health_data["hrv"], dream_time
                ),
                "heart_rate": HealthService._find_closest_value(
                    health_data["heart_rate"], dream_time
                )
            }
            correlations.append({
                "dream_id": dream["id"],
                "health_metrics": relevant_health
            })
        
        return correlations

    @staticmethod
    def _find_closest_value(metrics: list, target_time: datetime.datetime) -> Optional[float]:
        if not metrics:
            return None
            
        closest = min(
            metrics,
            key=lambda x: abs(
                datetime.datetime.fromisoformat(x["date"]) - target_time
            )
        )
        return closest["value"]