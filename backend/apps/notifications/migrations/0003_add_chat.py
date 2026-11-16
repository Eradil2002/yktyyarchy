# Generated manually for adding chat models

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('events', '0004_add_qr_code'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('notifications', '0002_add_indexes'),
    ]

    operations = [
        migrations.CreateModel(
            name='ChatRoom',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('event', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='chat_rooms', to='events.event')),
                ('ngo', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='ngo_chats', to=settings.AUTH_USER_MODEL)),
                ('volunteer', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='volunteer_chats', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['-updated_at'],
            },
        ),
        migrations.CreateModel(
            name='ChatMessage',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('message', models.TextField()),
                ('is_read', models.BooleanField(default=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('room', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='messages', to='notifications.chatroom')),
                ('sender', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='sent_messages', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['created_at'],
            },
        ),
        migrations.AddIndex(
            model_name='chatroom',
            index=models.Index(fields=['volunteer', 'updated_at'], name='notificatio_volunte_idx'),
        ),
        migrations.AddIndex(
            model_name='chatroom',
            index=models.Index(fields=['ngo', 'updated_at'], name='notificatio_ngo_upd_idx'),
        ),
        migrations.AddIndex(
            model_name='chatmessage',
            index=models.Index(fields=['room', 'created_at'], name='notificatio_room_cr_idx'),
        ),
        migrations.AddIndex(
            model_name='chatmessage',
            index=models.Index(fields=['room', 'is_read'], name='notificatio_room_is_idx'),
        ),
        migrations.AlterUniqueTogether(
            name='chatroom',
            unique_together={('event', 'volunteer', 'ngo')},
        ),
    ]
