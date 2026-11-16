from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import InitiativeViewSet

router = DefaultRouter()
router.register(r'', InitiativeViewSet, basename='initiative')

urlpatterns = [
    path('', include(router.urls)),
]
