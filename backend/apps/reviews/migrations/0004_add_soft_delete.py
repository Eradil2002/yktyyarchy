# Generated manually for adding soft delete fields to Review model

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('reviews', '0003_add_report'),
    ]

    operations = [
        migrations.AddField(
            model_name='review',
            name='deleted_at',
            field=models.DateTimeField(blank=True, db_index=True, null=True),
        ),
        migrations.AddField(
            model_name='review',
            name='deleted_by',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name='review_deleted',
                to=settings.AUTH_USER_MODEL
            ),
        ),
    ]
