# Generated manually for adding database indexes

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('initiatives', '0002_initial'),
    ]

    operations = [
        # Add indexes for Initiative model
        migrations.AddIndex(
            model_name='initiative',
            index=models.Index(fields=['category'], name='initiatives_category_idx'),
        ),
        migrations.AddIndex(
            model_name='initiative',
            index=models.Index(fields=['status'], name='initiatives_status_idx'),
        ),
        migrations.AddIndex(
            model_name='initiative',
            index=models.Index(fields=['created_at'], name='initiatives_created_idx'),
        ),
        migrations.AddIndex(
            model_name='initiative',
            index=models.Index(fields=['author', 'status'], name='initiatives_author_status_idx'),
        ),
        migrations.AddIndex(
            model_name='initiative',
            index=models.Index(fields=['latitude', 'longitude'], name='initiatives_location_idx'),
        ),
    ]
