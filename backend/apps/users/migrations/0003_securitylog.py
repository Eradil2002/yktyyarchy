# Generated manually for adding SecurityLog model

from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0002_add_indexes'),
    ]

    operations = [
        migrations.CreateModel(
            name='SecurityLog',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('event_type', models.CharField(choices=[('login_success', 'Успешный вход'), ('login_failed', 'Неудачная попытка входа'), ('logout', 'Выход'), ('password_change', 'Смена пароля'), ('password_reset_request', 'Запрос сброса пароля'), ('password_reset_complete', 'Сброс пароля завершен'), ('email_verification', 'Подтверждение email'), ('whatsapp_otp_request', 'Запрос WhatsApp OTP'), ('whatsapp_otp_verify', 'Проверка WhatsApp OTP'), ('registration', 'Регистрация'), ('account_locked', 'Блокировка аккаунта'), ('suspicious_activity', 'Подозрительная активность')], max_length=50)),
                ('ip_address', models.GenericIPAddressField(blank=True, null=True)),
                ('user_agent', models.TextField(blank=True)),
                ('username_attempted', models.CharField(blank=True, max_length=150)),
                ('details', models.JSONField(blank=True, default=dict)),
                ('timestamp', models.DateTimeField(db_index=True, default=django.utils.timezone.now)),
                ('user', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='security_logs', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['-timestamp'],
            },
        ),
        migrations.AddIndex(
            model_name='securitylog',
            index=models.Index(fields=['user', 'event_type'], name='users_secur_user_id_event_idx'),
        ),
        migrations.AddIndex(
            model_name='securitylog',
            index=models.Index(fields=['event_type', 'timestamp'], name='users_secur_event_t_time_idx'),
        ),
        migrations.AddIndex(
            model_name='securitylog',
            index=models.Index(fields=['ip_address', 'timestamp'], name='users_secur_ip_addr_time_idx'),
        ),
    ]
