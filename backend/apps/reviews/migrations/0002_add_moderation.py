# Generated manually for adding moderation fields to Review model

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('reviews', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='review',
            name='moderation_status',
            field=models.CharField(
                choices=[('pending', 'На модерации'), ('approved', 'Одобрен'), ('rejected', 'Отклонен')],
                default='approved',
                max_length=20
            ),
        ),
        migrations.AddField(
            model_name='review',
            name='moderated_by',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name='moderated_reviews',
                to=settings.AUTH_USER_MODEL
            ),
        ),
        migrations.AddField(
            model_name='review',
            name='moderated_at',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='review',
            name='moderation_reason',
            field=models.TextField(blank=True),
        ),
        migrations.AddIndex(
            model_name='review',
            index=models.Index(fields=['moderation_status'], name='reviews_rev_moderat_idx'),
        ),
    ]
