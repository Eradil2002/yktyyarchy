# Generated manually on 2026-04-13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('events', '0002_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='eventregistration',
            name='status',
            field=models.CharField(
                choices=[
                    ('pending', 'Ожидает'),
                    ('approved', 'Одобрено'),
                    ('rejected', 'Отклонено'),
                    ('attended', 'Посетил (часы начислены)'),
                    ('missed', 'Не пришел')
                ],
                default='pending',
                max_length=20
            ),
        ),
    ]
