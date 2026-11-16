import os
from celery import Celery
from celery.schedules import crontab

# Set the default Django settings module
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

app = Celery('volunteer_platform')

# Load config from Django settings
app.config_from_object('django.conf:settings', namespace='CELERY')

# Auto-discover tasks in all installed apps
app.autodiscover_tasks()

# Celery Beat schedule for periodic tasks
app.conf.beat_schedule = {
    'send-event-reminders-every-hour': {
        'task': 'apps.notifications.tasks.send_event_reminders',
        'schedule': crontab(minute=0),  # Every hour at minute 0
    },
    'cleanup-old-notifications-daily': {
        'task': 'apps.notifications.tasks.cleanup_old_notifications',
        'schedule': crontab(hour=2, minute=0),  # Every day at 2 AM
    },
    'archive-old-events-weekly': {
        'task': 'apps.events.tasks.archive_old_events_task',
        'schedule': crontab(hour=3, minute=0, day_of_week=1),  # Every Monday at 3 AM
    },
}

app.conf.timezone = 'UTC'


@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
