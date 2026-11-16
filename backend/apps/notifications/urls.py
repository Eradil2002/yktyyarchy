from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import FCMDeviceViewSet, NotificationViewSet
from .chat_views import ChatRoomViewSet, ChatMessageViewSet

router = DefaultRouter()
router.register(r'devices', FCMDeviceViewSet, basename='device')
router.register(r'chat/rooms', ChatRoomViewSet, basename='chatroom')
router.register(r'chat/messages', ChatMessageViewSet, basename='chatmessage')
router.register(r'', NotificationViewSet, basename='notification')

urlpatterns = [
    path('', include(router.urls)),
]
