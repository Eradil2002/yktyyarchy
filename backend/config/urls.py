from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from apps.users.search_views import GlobalSearchView
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView
from .health_views import health_check

urlpatterns = [
    path('admin/', admin.site.urls), # Django Admin
    path('health/', health_check, name='health-check'),

    # API v1 endpoints
    path('api/v1/users/', include('apps.users.urls')),
    path('api/v1/events/', include('apps.events.urls')),
    path('api/v1/initiatives/', include('apps.initiatives.urls')),
    path('api/v1/reviews/', include('apps.reviews.urls')),
    path('api/v1/notifications/', include('apps.notifications.urls')),
    path('api/v1/achievements/', include('apps.achievements.urls')),
    path('api/v1/search/', GlobalSearchView.as_view(), name='global-search'),

    # API base fallback endpoints (without v1) to support clients using API_URL ending in /api
    path('api/users/', include('apps.users.urls')),
    path('api/events/', include('apps.events.urls')),
    path('api/initiatives/', include('apps.initiatives.urls')),
    path('api/reviews/', include('apps.reviews.urls')),
    path('api/notifications/', include('apps.notifications.urls')),
    path('api/achievements/', include('apps.achievements.urls')),
    path('api/search/', GlobalSearchView.as_view(), name='global-search-base'),

    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    # Monitoring (#98)
    path('', include('django_prometheus.urls')),
]


if settings.DEBUG and not settings.USE_S3:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
