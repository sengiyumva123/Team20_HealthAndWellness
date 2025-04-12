# storage.py
from typing import Dict, List, Optional
from models import UserProfile
import json
import os

# In-memory storage (replace with database in production)
dream_logs: Dict[str, List] = {}
user_profiles: Dict[str, UserProfile] = {}

def store_dream(user_id: str, dream_data: Dict):
    """Store a dream log for a user"""
    if user_id not in dream_logs:
        dream_logs[user_id] = []
    dream_logs[user_id].append(dream_data)
    _save_to_file()

def get_user_logs(user_id: str) -> List[Dict]:
    """Retrieve all dream logs for a user"""
    return dream_logs.get(user_id, [])

def save_user_profile(profile: UserProfile):
    """Save or update a user profile"""
    user_profiles[profile.user_id] = profile
    _save_to_file()

def get_user_profile(user_id: str) -> Optional[UserProfile]:
    """Retrieve a user profile"""
    return user_profiles.get(user_id)

def _save_to_file():
    """Persist data to files (simple JSON storage)"""
    try:
        with open("dream_data.json", "w") as f:
            json.dump(dream_logs, f)
        with open("user_profiles.json", "w") as f:
            profiles_dict = {k: v.dict() for k, v in user_profiles.items()}
            json.dump(profiles_dict, f)
    except Exception as e:
        print(f"Error saving data: {e}")

def _load_from_file():
    """Load data from files"""
    global dream_logs, user_profiles
    try:
        if os.path.exists("dream_data.json"):
            with open("dream_data.json", "r") as f:
                dream_logs = json.load(f)
        if os.path.exists("user_profiles.json"):
            with open("user_profiles.json", "r") as f:
                profiles_dict = json.load(f)
                user_profiles = {k: UserProfile(**v) for k, v in profiles_dict.items()}
    except Exception as e:
        print(f"Error loading data: {e}")

# Initialize storage
_load_from_file()