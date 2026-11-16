# Generated manually for adding qr_code field to Event model

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('events', '0003_add_indexes'),
    ]

    operations = [
        migrations.AddField(
            model_name='event',
            name='qr_code',
            field=models.ImageField(blank=True, null=True, upload_to='qr_codes/'),
        ),
    ]
