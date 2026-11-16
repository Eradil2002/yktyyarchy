from rest_framework import viewsets, permissions
from .models import UserAchievement
from .serializers import UserAchievementSerializer

class UserAchievementViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = UserAchievementSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        queryset = UserAchievement.objects.all()
        user_id = self.request.query_params.get('user')
        if user_id:
            queryset = queryset.filter(user_id=user_id)
        elif self.request.user.is_authenticated:
            queryset = queryset.filter(user=self.request.user)
        return queryset
