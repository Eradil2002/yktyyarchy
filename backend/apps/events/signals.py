from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from .models import Event, EventRegistration
from apps.notifications.push_notifications import (
    notify_new_event,
    notify_registration_status
)
import logging

logger = logging.getLogger(__name__)


@receiver(post_save, sender=Event)
def event_created_notification(sender, instance, created, **kwargs):
    """
    Send push notification when a new event is created.
    """
    if created and instance.status == 'open':
        try:
            notify_new_event(instance)
        except Exception as e:
            logger.error(f"Error sending notification for new event {instance.id}: {e}")


@receiver(post_save, sender=EventRegistration)
def registration_status_notification(sender, instance, created, **kwargs):
    """
    Send push notification when registration status changes.
    """
    if not created:  # Only for updates, not new registrations
        try:
            if instance.status in ['approved', 'rejected', 'cancelled']:
                notify_registration_status(instance)
        except Exception as e:
            logger.error(f"Error sending registration status notification: {e}")
