from django.db import models
from django.conf import settings
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from simple_history.models import HistoricalRecords
from apps.events.models import Event
from apps.users.soft_delete import SoftDeleteModel

class Review(SoftDeleteModel):
    MODERATION_STATUS = (
        ('pending', 'На модерации'),
        ('approved', 'Одобрен'),
        ('rejected', 'Отклонен'),
    )

    reviewer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='reviews_given')
    target_user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='reviews_received')
    event = models.ForeignKey(Event, on_delete=models.SET_NULL, null=True, blank=True, related_name='reviews')

    rating = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    text = models.TextField()
    is_from_ngo = models.BooleanField(default=False)

    # Moderation fields
    moderation_status = models.CharField(max_length=20, choices=MODERATION_STATUS, default='approved')
    moderated_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='moderated_reviews')
    moderated_at = models.DateTimeField(null=True, blank=True)
    moderation_reason = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    # History tracking
    history = HistoricalRecords()

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.reviewer.username} -> {self.target_user.username} ({self.rating} stars)"


class Report(models.Model):
    """
    Universal report model for reporting inappropriate content.
    Can be used to report events, reviews, users, etc.
    """
    REPORT_TYPES = (
        ('spam', 'Спам'),
        ('inappropriate', 'Неприемлемый контент'),
        ('harassment', 'Домогательство'),
        ('fake', 'Фейковая информация'),
        ('other', 'Другое'),
    )

    STATUS_CHOICES = (
        ('pending', 'На рассмотрении'),
        ('reviewed', 'Рассмотрено'),
        ('resolved', 'Решено'),
        ('dismissed', 'Отклонено'),
    )

    # Reporter
    reporter = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='reports_made'
    )

    # Generic relation to any model
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE)
    object_id = models.PositiveIntegerField()
    content_object = GenericForeignKey('content_type', 'object_id')

    # Report details
    report_type = models.CharField(max_length=20, choices=REPORT_TYPES)
    description = models.TextField()

    # Moderation
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reports_reviewed'
    )
    reviewed_at = models.DateTimeField(null=True, blank=True)
    admin_notes = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', 'created_at']),
            models.Index(fields=['content_type', 'object_id']),
            models.Index(fields=['reporter']),
        ]

    def __str__(self):
        return f"Report by {self.reporter.username} - {self.report_type} ({self.status})"
