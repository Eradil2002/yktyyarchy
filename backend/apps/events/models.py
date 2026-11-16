from django.db import models
from django.conf import settings
from django.core.exceptions import ValidationError
from simple_history.models import HistoricalRecords
from apps.users.file_validators import validate_event_image, validate_image_extension
from apps.users.soft_delete import SoftDeleteModel

class Event(SoftDeleteModel):
    EVENT_TYPES = (
        ('online', 'Онлайн'),
        ('offline', 'Офлайн'),
    )
    STATUS_CHOICES = (
        ('open', 'Открыт'),
        ('closed', 'Закрыт'),
        ('completed', 'Завершен'),
    )
    
    title = models.CharField(max_length=255)
    description = models.TextField()
    organizer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='organized_events')
    category = models.CharField(max_length=100)
    date = models.DateTimeField()
    end_time = models.DateTimeField(blank=True, null=True)
    location = models.CharField(max_length=255)
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)
    type = models.CharField(max_length=20, choices=EVENT_TYPES, default='offline')
    hours = models.IntegerField()
    spots_total = models.IntegerField()
    
    requirements = models.JSONField(default=list, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open')
    is_urgent = models.BooleanField(default=False)
    image = models.ImageField(
        upload_to='events/',
        null=True,
        blank=True,
        validators=[validate_event_image, validate_image_extension]
    )
    qr_code = models.ImageField(upload_to='qr_codes/', null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    # History tracking
    history = HistoricalRecords()

    def __str__(self):
        return self.title

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

    @property
    def spots_booked(self):
        return self.registrations.filter(status='approved').count()


class EventRegistration(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Ожидает'),
        ('approved', 'Одобрено'),
        ('rejected', 'Отклонено'),
        ('attended', 'Посетил (часы начислены)'),
        ('missed', 'Не пришел'),
    )
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='registrations')
    volunteer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='event_registrations')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    registered_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('event', 'volunteer')

    def __str__(self):
        return f"{self.volunteer.username} -> {self.event.title}"
