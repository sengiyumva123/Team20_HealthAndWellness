import healthkit 

def get_sleep_data(user_id: str):
    sleep_data = healthkit.get_sleep_analysis()
    return {
        "deep_sleep_min": sleep_data["deep"],
        "rem_sleep_min": sleep_data["rem"],
        "sleep_score": sleep_data["score"]
    }