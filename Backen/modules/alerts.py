user_alert_settings = {
    "test_user": {"alerts_enabled": True}
}

def check_and_send_alerts(user_id):
    if user_alert_settings.get(user_id, {}).get("alerts_enabled"):
        print(f"[Alert] Insights sent to user {user_id}")
