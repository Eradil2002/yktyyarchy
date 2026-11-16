import logging
from django.db import models
from django.conf import settings
from firebase_admin import messaging
from rest_framework import serializers
from django.db.models.signals import pre_delete
from django.dispatch import receiver

logger = logging.getLogger(__name__)

class FCMDevice(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='fcm_devices'
    )
    registration_id = models.TextField(unique=True)
    device_type = models.CharField(max_length=20, choices=(('android', 'Android'), ('ios', 'iOS')), default='android')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def send_notification(self, title, body, data=None):
        """Sends a single push notification to this device."""
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=self.registration_id,
        )
        try:
            response = messaging.send(message)
            return response
        except Exception as e:
            # Token might be invalid/expired, usually we'd delete it here in a real app
            logger.warning(f"Error sending push: {e}")
            return None

class Notification(models.Model):
    NOTIFICATION_TYPES = (
        ('invitation', 'Приглашение'),
        ('registration_status', 'Статус регистрации'),
        ('event_update', 'Обновление мероприятия'),
        ('system', 'Системное'),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES, default='system')
    title = models.CharField(max_length=255)
    body = models.TextField()
    is_read = models.BooleanField(default=False)
    data = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} for {self.user.username}"

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super().save(*args, **kwargs)
        if is_new:
            # Auto-send push notifications
            try:
                devices = FCMDevice.objects.filter(user=self.user)
                for device in devices:
                    try:
                        device.send_notification(self.title, self.body, self.data)
                    except Exception as e:
                        logger.warning(f"Failed to send notification to device {device.id}: {e}")
            except Exception as e:
                logger.warning(f"Failed to send push notifications: {e}")


@receiver(pre_delete, sender=settings.AUTH_USER_MODEL)
def cleanup_fcm_tokens(sender, instance, **kwargs):
    """Clean up FCM tokens from Firebase when user is deleted"""
    try:
        devices = FCMDevice.objects.filter(user=instance)
        for device in devices:
            try:
                # Unregister token from Firebase
                messaging.unsubscribe_from_topic([device.registration_id], 'all_users')
            except Exception as e:
                logger.warning(f"Failed to unregister FCM token {device.registration_id}: {e}")
    except Exception as e:
        logger.warning(f"Failed to cleanup FCM tokens for user {instance.id}: {e}")


class ChatRoom(models.Model):
    """
    Chat room between volunteer and NGO for a specific event.
    """
    event = models.ForeignKey('events.Event', on_delete=models.CASCADE, related_name='chat_rooms')
    volunteer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='volunteer_chats')
    ngo = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='ngo_chats')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['event', 'volunteer', 'ngo']
        ordering = ['-updated_at']
        indexes = [
            models.Index(fields=['volunteer', 'updated_at']),
            models.Index(fields=['ngo', 'updated_at']),
        ]

    def __str__(self):
        return f"Chat: {self.volunteer.username} - {self.ngo.username} (Event: {self.event.title})"


class ChatMessage(models.Model):
    """
    Individual message in a chat room.
    """
    room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='sent_messages')
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['room', 'created_at']),
            models.Index(fields=['room', 'is_read']),
        ]

    def __str__(self):
        return f"{self.sender.username}: {self.message[:50]}"
