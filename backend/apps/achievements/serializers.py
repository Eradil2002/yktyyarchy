from rest_framework import serializers
from .models import Achievement, UserAchievement

class AchievementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Achievement
        fields = ('id', 'title', 'description', 'icon_url', 'requirement_type', 'requirement_value')

class UserAchievementSerializer(serializers.ModelSerializer):
    achievement = AchievementSerializer(read_only=True)
    
    class Meta:
        model = UserAchievement
        fields = ('id', 'achievement', 'earned_at')
