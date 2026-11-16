from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import FCMDevice, Notification
from .serializers import FCMDeviceSerializer, NotificationSerializer

class FCMDeviceViewSet(viewsets.ModelViewSet):
    queryset = FCMDevice.objects.all()
    serializer_class = FCMDeviceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        # update_or_create to avoid duplicates for the same token
        FCMDevice.objects.update_or_create(
            registration_id=serializer.validated_data['registration_id'],
            defaults={
                'user': self.request.user,
                'device_type': serializer.validated_data.get('device_type', 'android')
            }
        )

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)


class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

    @action(detail=False, methods=['post'])
    def mark_all_as_read(self, request):
        self.get_queryset().update(is_read=True)
        return Response({'status': 'notifications marked as read'})

    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'status': 'notification marked as read'})
