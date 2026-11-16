from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.users.models import CustomUser
from apps.events.models import EventRegistration
from apps.initiatives.models import Initiative
from .models import Achievement, UserAchievement

@receiver(post_save, sender=CustomUser)
def check_user_stats_achievements(sender, instance, **kwargs):
    """Автоматически проверяет достижения по часам и рейтингу"""
    if instance.role != 'volunteer':
        return

    # Часы
    hours_achievements = Achievement.objects.filter(
        requirement_type='hours',
        requirement_value__lte=instance.total_hours
    )
    
    # Рейтинг
    rating_achievements = Achievement.objects.filter(
        requirement_type='rating',
        requirement_value__lte=instance.rating
    )

    all_eligible = list(hours_achievements) + list(rating_achievements)
    for ach in all_eligible:
        UserAchievement.objects.get_or_create(user=instance, achievement=ach)

@receiver(post_save, sender=EventRegistration)
def check_event_achievements(sender, instance, **kwargs):
    """Автоматически проверяет достижения за количество мероприятий"""
    if instance.status == 'attended':
        volunteer = instance.volunteer
        events_count = EventRegistration.objects.filter(volunteer=volunteer, status='attended').count()
        
        achievements = Achievement.objects.filter(
            requirement_type='events',
            requirement_value__lte=events_count
        )
        for ach in achievements:
            UserAchievement.objects.get_or_create(user=volunteer, achievement=ach)

@receiver(post_save, sender=Initiative)
def check_initiative_achievements(sender, instance, **kwargs):
    """Автоматически проверяет достижения за личные инициативы"""
    if instance.status == 'approved':
        author = instance.author
        initiatives_count = Initiative.objects.filter(author=author, status='approved').count()
        
        achievements = Achievement.objects.filter(
            requirement_type='initiatives',
            requirement_value__lte=initiatives_count
        )
        for ach in achievements:
            UserAchievement.objects.get_or_create(user=author, achievement=ach)
