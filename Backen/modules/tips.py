# tips.py
from typing import List, Dict, Optional

TIP_DATABASE = {
    "general": [
        "Maintain a consistent sleep schedule, even on weekends.",
        "Keep your bedroom cool, dark, and quiet for better sleep."
    ],
    "negative_emotion": [
        "Try journaling about your day before bed to process emotions.",
        "A warm bath before sleep may help ease negative thoughts."
    ],
    "falling": [
        "Falling dreams may indicate anxiety - try progressive muscle relaxation.",
        "Establish a consistent bedtime routine to regain sense of control."
    ],
    "chased": [
        "Being chased in dreams often relates to avoidance. Consider facing small challenges daily.",
        "Try visualization techniques where you confront what's chasing you."
    ],
    "lion": [
        "As a lion chronotype, you naturally wake early. Try to wind down by 9PM.",
        "Morning sunlight exposure will help regulate your natural rhythm."
    ],
    "bear": [
        "Your energy follows the sun. Aim for 7-8 hours of sleep during night hours.",
        "Schedule important tasks between 10AM-2PM when you're most productive."
    ],
    "wolf": [
        "Night owl tendencies mean you should protect your morning sleep.",
        "Consider blackout curtains to help you sleep later in the morning."
    ],
    "dolphin": [
        "Light sleepers benefit from white noise machines or earplugs.",
        "Try magnesium supplements before bed to improve sleep quality."
    ]
}

def generate_tips(
    emotions: List[Dict],
    archetypes: List[str],
    stress_level: Optional[int] = None,
    sleep_quality: Optional[int] = None,
    chronotype: Optional[str] = None
) -> List[str]:
    """Generate personalized tips based on dream analysis"""
    tips = set()
    
    # Add general tips
    tips.update(TIP_DATABASE["general"])
    
    # Emotion-based tips
    if any(e["label"] in ["FEAR", "ANGER", "SADNESS"] for e in emotions):
        tips.update(TIP_DATABASE["negative_emotion"])
    
    # Archetype-based tips
    for archetype in archetypes:
        if archetype in TIP_DATABASE:
            tips.update(TIP_DATABASE[archetype])
    
    # Chronotype tips
    if chronotype and chronotype in TIP_DATABASE:
        tips.update(TIP_DATABASE[chronotype])
    
    # Stress and sleep quality tips
    if stress_level and stress_level > 7:
        tips.add("High stress detected: Try 4-7-8 breathing technique before bed.")
    if sleep_quality and sleep_quality < 3:
        tips.add("Poor sleep quality: Consider reducing caffeine intake after 2PM.")
    
    return list(tips)[:5]  # Return max 5 most relevant tips