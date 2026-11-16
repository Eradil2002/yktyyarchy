# Generated manually for adding soft delete fields to Initiative model

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('initiatives', '0003_add_indexes'),
    ]

    operations = [
        migrations.AddField(
            model_name='initiative',
            name='deleted_at',
            field=models.DateTimeField(blank=True, db_index=True, null=True),
        ),
        migrations.AddField(
            model_name='initiative',
            name='deleted_by',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name='initiative_deleted',
                to=settings.AUTH_USER_MODEL
            ),
        ),
    ]
