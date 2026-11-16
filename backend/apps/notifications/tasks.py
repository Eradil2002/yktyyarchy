from celery import shared_task
from django.utils import timezone
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)


@shared_task
def send_event_reminders():
    """
    Celery task to send event reminders.
    Should be run periodically (e.g., every hour).
    """
    from apps.events.models import Event
    from apps.notifications.push_notifications import notify_event_reminder

    now = timezone.now()

    # Find events happening in 24 hours
    events_24h = Event.objects.filter(
        status='open',
        date__gte=now + timedelta(hours=23),
        date__lte=now + timedelta(hours=25)
    )

    for event in events_24h:
        try:
            notify_event_reminder(event, hours_before=24)
            logger.info(f"Sent 24h reminder for event {event.id}")
        except Exception as e:
            logger.error(f"Error sending 24h reminder for event {event.id}: {e}")

    # Find events happening in 1 hour
    events_1h = Event.objects.filter(
        status='open',
        date__gte=now + timedelta(minutes=50),
        date__lte=now + timedelta(minutes=70)
    )

    for event in events_1h:
        try:
            notify_event_reminder(event, hours_before=1)
            logger.info(f"Sent 1h reminder for event {event.id}")
        except Exception as e:
            logger.error(f"Error sending 1h reminder for event {event.id}: {e}")

    return {
        'reminders_24h': events_24h.count(),
        'reminders_1h': events_1h.count()
    }


@shared_task
def cleanup_old_notifications():
    """
    Clean up old notifications (older than 30 days).
    """
    from apps.notifications.models import Notification

    cutoff_date = timezone.now() - timedelta(days=30)
    deleted_count = Notification.objects.filter(created_at__lt=cutoff_date).delete()[0]

    logger.info(f"Cleaned up {deleted_count} old notifications")
    return deleted_count
