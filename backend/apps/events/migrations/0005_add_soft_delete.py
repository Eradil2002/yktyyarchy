# Generated manually for adding soft delete fields to Event model

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('events', '0004_add_qr_code'),
    ]

    operations = [
        migrations.AddField(
            model_name='event',
            name='deleted_at',
            field=models.DateTimeField(blank=True, db_index=True, null=True),
        ),
        migrations.AddField(
            model_name='event',
            name='deleted_by',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name='event_deleted',
                to=settings.AUTH_USER_MODEL
            ),
        ),
    ]
