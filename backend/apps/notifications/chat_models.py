from django.db import models
from django.conf import settings


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
