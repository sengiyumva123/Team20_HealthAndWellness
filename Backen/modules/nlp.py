# nlp.py
from transformers import pipeline
import spacy
from typing import List, Dict

# Load models once
emotion_classifier = pipeline("text-classification", model="bhadresh-savani/distilbert-base-uncased-emotion")
nlp = spacy.load("en_core_web_sm")

EMOTION_COLORS = {
    "joy": "#FFD700",     # Gold
    "fear": "#800080",    # Purple
    "anger": "#FF0000",   # Red
    "sadness": "#1E90FF", # Blue
    "neutral": "#808080",  # Gray
    "surprise": "#FFA500", # Orange
    "disgust": "#008000",  # Green
    "unknown": "#000000"   # Black
}

def classify_emotion(text: str) -> List[Dict]:
    """Classify emotions in text and return with color coding"""
    try:
        # Truncate to model max length and handle empty text
        if not text or not text.strip():
            return [{"label": "unknown", "score": 0.0, "color": EMOTION_COLORS["unknown"]}]
            
        result = emotion_classifier(text[:512])
        return [
            {
                "label": r["label"].lower(),  # Ensure lowercase for consistent matching
                "score": round(r["score"], 2),
                "color": EMOTION_COLORS.get(r["label"].lower(), EMOTION_COLORS["unknown"])
            }
            for r in result
        ]
    except Exception as e:
        print(f"Emotion classification error: {e}")
        return [{"label": "unknown", "score": 0.0, "color": EMOTION_COLORS["unknown"]}]

def detect_archetypes(text: str) -> List[str]:
    """Detect common dream archetypes from text"""
    if not text or not text.strip():
        return []
        
    archetypes = set()  # Use set to avoid duplicates
    doc = nlp(text.lower())
    
    patterns = {
        "falling": ["fall", "slip", "trip", "plummet"],
        "chased": ["chase", "pursue", "flee", "escape"],
        "teeth": ["tooth", "teeth", "dentist"],
        "flying": ["fly", "float", "soar", "airborne"],
        "naked": ["naked", "nude", "exposed", "undressed"],
        "test": ["exam", "test", "fail", "study"],
        "vehicle": ["car", "drive", "plane", "vehicle"],
        "death": ["die", "death", "dead", "kill"],
        "water": ["water", "ocean", "swim", "drown"]
    }
    
    for token in doc:
        for archetype, keywords in patterns.items():
            if token.lemma_ in keywords:
                archetypes.add(archetype)
    
    return sorted(archetypes)  # Return sorted list for consistency