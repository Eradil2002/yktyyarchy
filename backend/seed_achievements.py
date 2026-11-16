from apps.achievements.models import Achievement

def seed_achievements():
    achievements = [
        {
            "title": "Новичок",
            "description": "Отработано более 1 часа волонтерства",
            "requirement_type": "hours",
            "requirement_value": 1,
            "icon_url": "stars"
        },
        {
            "title": "Активный волонтер",
            "description": "Отработано более 10 часов волонтерства",
            "requirement_type": "hours",
            "requirement_value": 10,
            "icon_url": "volunteer_activism"
        },
        {
            "title": "Герой сообщества",
            "description": "Отработано более 50 часов волонтерства",
            "requirement_type": "hours",
            "requirement_value": 50,
            "icon_url": "workspace_premium"
        },
        {
            "title": "Легенда",
            "description": "Отработано более 100 часов волонтерства",
            "requirement_type": "hours",
            "requirement_value": 100,
            "icon_url": "military_tech"
        },
        {
            "title": "Первый шаг",
            "description": "Участие в первом официальном мероприятии",
            "requirement_type": "events",
            "requirement_value": 1,
            "icon_url": "directions_run"
        },
        {
            "title": "Социальный активист",
            "description": "Участие в 5 официальных мероприятиях",
            "requirement_type": "events",
            "requirement_value": 5,
            "icon_url": "groups"
        },
        {
            "title": "Инициатор",
            "description": "Создана первая личная инициатива (доброе дело)",
            "requirement_type": "initiatives",
            "requirement_value": 1,
            "icon_url": "lightbulb"
        },
    ]

    for data in achievements:
        Achievement.objects.get_or_create(
            requirement_type=data["requirement_type"],
            requirement_value=data["requirement_value"],
            defaults={
                "title": data["title"],
                "description": data["description"],
                "icon_url": data["icon_url"]
            }
        )
    print("✓ Достижения успешно созданы.")

if __name__ == "__main__":
    seed_achievements()
