
from datetime import datetime, timedelta
from collections import defaultdict, Counter
from typing import Dict, List
from models import UserProfile

def generate_weekly_report(user_id: str, logs: List[Dict]) -> Dict:
    """Generate comprehensive weekly dream analysis report"""
    if not logs:
        return {"error": "No dreams logged this week"}
    
    # Filter last week's logs
    last_week = datetime.now() - timedelta(days=7)
    week_logs = [log for log in logs if datetime.fromisoformat(log["timestamp"]) >= last_week]
    
    # Calculate metrics
    mood_counts = Counter()
    archetype_counts = Counter()
    sleep_qualities = []
    
    for log in week_logs:
        for emotion in log.get("emotions", []):
            mood_counts[emotion["label"]] += 1
        for archetype in log.get("archetypes", []):
            archetype_counts[archetype] += 1
        if "sleep_quality" in log:
            sleep_qualities.append(log["sleep_quality"])
    
    # Generate insights
    avg_sleep = sum(sleep_qualities)/len(sleep_qualities) if sleep_qualities else None
    dominant_emotion = mood_counts.most_common(1)[0][0] if mood_counts else None
    common_archetype = archetype_counts.most_common(1)[0][0] if archetype_counts else None
    
    return {
        "period": f"{last_week.date()} to {datetime.now().date()}",
        "dream_count": len(week_logs),
        "dominant_emotion": dominant_emotion,
        "common_archetype": common_archetype,
        "avg_sleep_quality": round(avg_sleep, 1) if avg_sleep else None,
        "mood_distribution": dict(mood_counts),
        "archetype_frequency": dict(archetype_counts),
        "journal_prompts": generate_journal_prompts(week_logs)
    }

def generate_journal_prompts(logs: List[Dict]) -> List[str]:
    """Generate personalized journal prompts based on dream patterns"""
    prompts = []
    archetypes = [a for log in logs for a in log.get("archetypes", [])]
    emotions = [e["label"] for log in logs for e in log.get("emotions", [])]
    
    if "falling" in archetypes:
        prompts.append("Falling dreams often relate to control. What aspects of your life feel unstable?")
    if "chased" in archetypes:
        prompts.append("Being chased may represent avoidance. What are you running from in waking life?")
    if "SADNESS" in emotions:
        prompts.append("Your dreams showed sadness. What recent events might be affecting your mood?")
    
    if not prompts:
        prompts.append("Reflect on any recurring symbols or themes in your dreams this week.")
    
    return prompts