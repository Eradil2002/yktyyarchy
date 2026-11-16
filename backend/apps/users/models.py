from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone
from datetime import timedelta
from .file_validators import validate_avatar, validate_image_extension

class CustomUser(AbstractUser):
    ROLE_CHOICES = (
        ('volunteer', 'Волонтер'),
        ('ngo', 'НКО'),
        ('admin', 'Администратор'),
    )

    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='volunteer')
    phone = models.CharField(max_length=20, blank=True, null=True)
    avatar = models.ImageField(
        upload_to='avatars/',
        blank=True,
        null=True,
        validators=[validate_avatar, validate_image_extension]
    )
    location = models.CharField(max_length=255, blank=True, null=True)

    # Common stats
    total_hours = models.IntegerField(default=0)
    rating = models.FloatField(default=0.0)
    is_verified = models.BooleanField(default=False)

    # Email verification
    email_verified = models.BooleanField(default=False)
    email_verification_code = models.CharField(max_length=6, blank=True, null=True)
    email_verification_code_created = models.DateTimeField(blank=True, null=True)

    def __str__(self):
        return f"{self.get_full_name() or self.username} ({self.role})"

    def is_email_verification_code_valid(self):
        """Check if email verification code is still valid (24 hours)"""
        if not self.email_verification_code_created:
            return False
        expiry = self.email_verification_code_created + timedelta(hours=24)
        return timezone.now() < expiry

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['phone'],
                condition=models.Q(phone__isnull=False) & ~models.Q(phone=''),
                name='unique_phone_when_not_null'
            )
        ]


class VolunteerProfile(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='volunteer_profile')
    skills = models.JSONField(default=list, blank=True) # List of skills
    bio = models.TextField(blank=True, null=True)
    fcm_token = models.CharField(max_length=255, blank=True, null=True)  # Firebase Cloud Messaging token

    def __str__(self):
        return f"Волонтер: {self.user.username}"


class NGOProfile(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='ngo_profile')
    org_name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    contact_email = models.EmailField(blank=True, null=True)
    website = models.URLField(blank=True, null=True)
    fcm_token = models.CharField(max_length=255, blank=True, null=True)  # Firebase Cloud Messaging token

    def __str__(self):
        return f"НКО: {self.org_name}"
