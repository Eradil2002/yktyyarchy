# Generated manually for adding database indexes

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('events', '0002_initial'),
    ]

    operations = [
        # Add indexes for Event model
        migrations.AddIndex(
            model_name='event',
            index=models.Index(fields=['category'], name='events_event_category_idx'),
        ),
        migrations.AddIndex(
            model_name='event',
            index=models.Index(fields=['date'], name='events_event_date_idx'),
        ),
        migrations.AddIndex(
            model_name='event',
            index=models.Index(fields=['status'], name='events_event_status_idx'),
        ),
        migrations.AddIndex(
            model_name='event',
            index=models.Index(fields=['is_urgent'], name='events_event_urgent_idx'),
        ),
        migrations.AddIndex(
            model_name='event',
            index=models.Index(fields=['latitude', 'longitude'], name='events_event_location_idx'),
        ),
        migrations.AddIndex(
            model_name='event',
            index=models.Index(fields=['organizer', 'status'], name='events_event_org_status_idx'),
        ),
        migrations.AddIndex(
            model_name='event',
            index=models.Index(fields=['date', 'status'], name='events_event_date_status_idx'),
        ),

        # Add indexes for EventRegistration model
        migrations.AddIndex(
            model_name='eventregistration',
            index=models.Index(fields=['volunteer', 'status'], name='events_reg_vol_status_idx'),
        ),
        migrations.AddIndex(
            model_name='eventregistration',
            index=models.Index(fields=['event', 'status'], name='events_reg_event_status_idx'),
        ),
    ]
