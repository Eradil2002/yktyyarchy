from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserAchievementViewSet

router = DefaultRouter()
router.register(r'', UserAchievementViewSet, basename='userachievement')

urlpatterns = [
    path('', include(router.urls)),
]
