"""
Unit tests for achievement models.
"""
import pytest
from apps.achievements.models import Achievement, UserAchievement
from apps.users.models import CustomUser


@pytest.mark.django_db
class TestAchievement:
    """Test Achievement model."""

    def test_create_achievement(self):
        """Test creating an achievement."""
        achievement = Achievement.objects.create(
            title='First Event',
            description='Complete your first event',
            requirement_type='events',
            requirement_value=1
        )
        assert achievement.title == 'First Event'
        assert achievement.requirement_type == 'events'
        assert achievement.requirement_value == 1

    def test_achievement_str(self):
        """Test achievement string representation."""
        achievement = Achievement.objects.create(
            title='100 Hours',
            description='Complete 100 hours',
            requirement_type='hours',
            requirement_value=100
        )
        assert str(achievement) == '100 Hours'


@pytest.mark.django_db
class TestUserAchievement:
    """Test UserAchievement model."""

    def test_create_user_achievement(self, volunteer_user):
        """Test creating user achievement."""
        achievement = Achievement.objects.create(
            title='Test Achievement',
            description='Test',
            requirement_type='hours',
            requirement_value=10
        )
        
        user_achievement = UserAchievement.objects.create(
            user=volunteer_user,
            achievement=achievement
        )
        
        assert user_achievement.user == volunteer_user
        assert user_achievement.achievement == achievement

    def test_user_achievement_str(self, volunteer_user):
        """Test user achievement string representation."""
        achievement = Achievement.objects.create(
            title='My Achievement',
            description='Test',
            requirement_type='events',
            requirement_value=5
        )
        
        user_achievement = UserAchievement.objects.create(
            user=volunteer_user,
            achievement=achievement
        )
        
        assert str(user_achievement) == f"{volunteer_user.username} - My Achievement"

    def test_unique_user_achievement(self, volunteer_user):
        """Test unique constraint on user-achievement pair."""
        achievement = Achievement.objects.create(
            title='Test',
            description='Test',
            requirement_type='hours',
            requirement_value=10
        )
        
        UserAchievement.objects.create(
            user=volunteer_user,
            achievement=achievement
        )
        
        with pytest.raises(Exception):  # IntegrityError
            UserAchievement.objects.create(
                user=volunteer_user,
                achievement=achievement
            )
