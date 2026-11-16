from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ReviewViewSet, ReportViewSet

# /api/v1/reviews/          -> reviews list (used by the Flutter app: 'reviews/?target=<id>')
# /api/v1/reviews/reports/  -> reports
# 'reports' is registered first so it is not captured by the review detail route.
router = DefaultRouter()
router.include_root_view = False
router.register(r'reports', ReportViewSet, basename='report')
router.register(r'', ReviewViewSet, basename='review')

urlpatterns = [
    path('', include(router.urls)),
]
