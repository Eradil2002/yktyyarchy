# Generated manually for adding database indexes

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0002_alter_customuser_options_and_more'),
    ]

    operations = [
        # Add indexes for CustomUser model
        migrations.AddIndex(
            model_name='customuser',
            index=models.Index(fields=['role'], name='users_role_idx'),
        ),
        migrations.AddIndex(
            model_name='customuser',
            index=models.Index(fields=['is_verified'], name='users_verified_idx'),
        ),
        migrations.AddIndex(
            model_name='customuser',
            index=models.Index(fields=['email_verified'], name='users_email_verified_idx'),
        ),
        migrations.AddIndex(
            model_name='customuser',
            index=models.Index(fields=['rating'], name='users_rating_idx'),
        ),
        migrations.AddIndex(
            model_name='customuser',
            index=models.Index(fields=['total_hours'], name='users_hours_idx'),
        ),
        migrations.AddIndex(
            model_name='customuser',
            index=models.Index(fields=['role', 'rating'], name='users_role_rating_idx'),
        ),
    ]
