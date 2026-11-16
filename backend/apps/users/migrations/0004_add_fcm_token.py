# Generated manually for adding fcm_token to profiles

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0003_securitylog'),
    ]

    operations = [
        migrations.AddField(
            model_name='volunteerprofile',
            name='fcm_token',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
        migrations.AddField(
            model_name='ngoprofile',
            name='fcm_token',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]
