dream_logs = {}

def store_dream(user_id, dream_data, emotions, archetypes, tips):
    entry = {
        **dream_data,
        "emotions": emotions,
        "archetypes": archetypes,
        "tips": tips
    }
    if user_id not in dream_logs:
        dream_logs[user_id] = []
    dream_logs[user_id].append(entry)
