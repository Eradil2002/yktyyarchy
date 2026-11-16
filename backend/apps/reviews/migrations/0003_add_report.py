# Generated manually for adding Report model

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('contenttypes', '0002_remove_content_type_name'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('reviews', '0002_add_moderation'),
    ]

    operations = [
        migrations.CreateModel(
            name='Report',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('object_id', models.PositiveIntegerField()),
                ('report_type', models.CharField(
                    choices=[
                        ('spam', 'Спам'),
                        ('inappropriate', 'Неприемлемый контент'),
                        ('harassment', 'Домогательство'),
                        ('fake', 'Фейковая информация'),
                        ('other', 'Другое')
                    ],
                    max_length=20
                )),
                ('description', models.TextField()),
                ('status', models.CharField(
                    choices=[
                        ('pending', 'На рассмотрении'),
                        ('reviewed', 'Рассмотрено'),
                        ('resolved', 'Решено'),
                        ('dismissed', 'Отклонено')
                    ],
                    default='pending',
                    max_length=20
                )),
                ('reviewed_at', models.DateTimeField(blank=True, null=True)),
                ('admin_notes', models.TextField(blank=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('content_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='contenttypes.contenttype')),
                ('reporter', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='reports_made', to=settings.AUTH_USER_MODEL)),
                ('reviewed_by', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='reports_reviewed', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
        migrations.AddIndex(
            model_name='report',
            index=models.Index(fields=['status', 'created_at'], name='reviews_rep_status_created_idx'),
        ),
        migrations.AddIndex(
            model_name='report',
            index=models.Index(fields=['content_type', 'object_id'], name='reviews_rep_content_object_idx'),
        ),
        migrations.AddIndex(
            model_name='report',
            index=models.Index(fields=['reporter'], name='reviews_rep_reporter_idx'),
        ),
    ]
