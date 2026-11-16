from django.db import models
from django.conf import settings
from django.core.exceptions import ValidationError
from simple_history.models import HistoricalRecords
from apps.users.soft_delete import SoftDeleteModel

class Initiative(SoftDeleteModel):
    STATUS_CHOICES = (
        ('pending', 'На модерации'),
        ('approved', 'Одобрено'),
        ('rejected', 'Отклонено'),
    )
    
    title = models.CharField(max_length=255)
    description = models.TextField()
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='initiatives')
    category = models.CharField(max_length=100)
    location = models.CharField(max_length=255)
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)
    
    hours_claimed = models.IntegerField(default=1)
    
    # Store lists of image URLs or use related models. Simple approach for MVP:
    before_photos = models.JSONField(default=list, blank=True)
    after_photos = models.JSONField(default=list, blank=True)
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)

    # History tracking
    history = HistoricalRecords()

    def __str__(self):
        return f"{self.title} by {self.author.username}"

    def clean(self):
        """Validate latitude and longitude"""
        if self.latitude is not None:
            if self.latitude < -90 or self.latitude > 90:
                raise ValidationError({'latitude': 'Latitude must be between -90 and 90'})

        if self.longitude is not None:
            if self.longitude < -180 or self.longitude > 180:
                raise ValidationError({'longitude': 'Longitude must be between -180 and 180'})

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)
