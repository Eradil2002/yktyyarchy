# Generated manually for adding database indexes

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('notifications', '0002_notification'),
    ]

    operations = [
        # Add indexes for Notification model
        migrations.AddIndex(
            model_name='notification',
            index=models.Index(fields=['user', 'is_read'], name='notif_user_read_idx'),
        ),
        migrations.AddIndex(
            model_name='notification',
            index=models.Index(fields=['user', 'created_at'], name='notif_user_created_idx'),
        ),
        migrations.AddIndex(
            model_name='notification',
            index=models.Index(fields=['type'], name='notif_type_idx'),
        ),

        # Add indexes for FCMDevice model
        migrations.AddIndex(
            model_name='fcmdevice',
            index=models.Index(fields=['user'], name='fcm_user_idx'),
        ),
    ]
