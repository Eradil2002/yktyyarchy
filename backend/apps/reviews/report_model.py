from django.db import models
from django.conf import settings
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType


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
