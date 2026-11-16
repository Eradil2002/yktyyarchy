from django.db import models
from django.conf import settings

class Achievement(models.Model):
    ACHIEVEMENT_TYPES = (
        ('hours', 'Часы волонтерства'),
        ('events', 'Количество мероприятий'),
        ('initiatives', 'Количество инициатив'),
        ('rating', 'Рейтинг'),
        ('special', 'Специальное'),
    )

    title = models.CharField(max_length=100, verbose_name="Название")
    description = models.TextField(verbose_name="Описание")
    icon_url = models.CharField(max_length=255, blank=True, null=True, verbose_name="Иконка (URL или код)")
    
    requirement_type = models.CharField(max_length=20, choices=ACHIEVEMENT_TYPES, verbose_name="Тип условия")
    requirement_value = models.IntegerField(verbose_name="Значение условия")

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

    class Meta:
        verbose_name = "Достижение"
        verbose_name_plural = "Достижения"


class UserAchievement(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='achievements')
    achievement = models.ForeignKey(Achievement, on_delete=models.CASCADE)
    earned_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'achievement')
        verbose_name = "Достижение пользователя"
        verbose_name_plural = "Достижения пользователей"

    def __str__(self):
        return f"{self.user.username} - {self.achievement.title}"
