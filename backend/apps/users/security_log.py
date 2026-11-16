from django.db import models
from django.conf import settings
from django.utils import timezone


class SecurityLog(models.Model):
    """Audit log for security-related events"""

    EVENT_TYPES = (
        ('login_success', 'Успешный вход'),
        ('login_failed', 'Неудачная попытка входа'),
        ('logout', 'Выход'),
        ('password_change', 'Смена пароля'),
        ('password_reset_request', 'Запрос сброса пароля'),
        ('password_reset_complete', 'Сброс пароля завершен'),
        ('email_verification', 'Подтверждение email'),
        ('whatsapp_otp_request', 'Запрос WhatsApp OTP'),
        ('whatsapp_otp_verify', 'Проверка WhatsApp OTP'),
        ('registration', 'Регистрация'),
        ('account_locked', 'Блокировка аккаунта'),
        ('suspicious_activity', 'Подозрительная активность'),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='security_logs'
    )
    event_type = models.CharField(max_length=50, choices=EVENT_TYPES)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    username_attempted = models.CharField(max_length=150, blank=True)
    details = models.JSONField(default=dict, blank=True)
    timestamp = models.DateTimeField(default=timezone.now, db_index=True)

    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['user', 'event_type']),
            models.Index(fields=['event_type', 'timestamp']),
            models.Index(fields=['ip_address', 'timestamp']),
        ]

    def __str__(self):
        return f"{self.event_type} - {self.user or self.username_attempted} at {self.timestamp}"


def log_security_event(event_type, request=None, user=None, username=None, details=None):
    """Helper function to log security events"""
    ip_address = None
    user_agent = ''

    if request:
        # Get IP address
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip_address = x_forwarded_for.split(',')[0]
        else:
            ip_address = request.META.get('REMOTE_ADDR')

        # Get user agent
        user_agent = request.META.get('HTTP_USER_AGENT', '')

    SecurityLog.objects.create(
        user=user,
        event_type=event_type,
        ip_address=ip_address,
        user_agent=user_agent,
        username_attempted=username or '',
        details=details or {}
    )
