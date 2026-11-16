from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q
from .models import ChatRoom, ChatMessage
from .chat_serializers import ChatRoomSerializer, ChatMessageSerializer
from apps.users.sanitizers import sanitize_text_input


class ChatRoomViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing chat rooms.
    """
    serializer_class = ChatRoomSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        # Return chat rooms where user is either volunteer or ngo
        return ChatRoom.objects.filter(
            Q(volunteer=user) | Q(ngo=user)
        ).select_related('volunteer', 'ngo', 'event').prefetch_related('messages')

    def perform_create(self, serializer):
        # Auto-set volunteer or ngo based on user role
        user = self.request.user
        if user.role == 'volunteer':
            serializer.save(volunteer=user)
        elif user.role == 'ngo':
            serializer.save(ngo=user)

    @action(detail=True, methods=['get'])
    def messages(self, request, pk=None):
        """
        Get all messages in a chat room.
        """
        room = self.get_object()
        messages = room.messages.all()

        # Mark messages as read
        messages.filter(is_read=False).exclude(sender=request.user).update(is_read=True)

        serializer = ChatMessageSerializer(messages, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def send_message(self, request, pk=None):
        """
        Send a message in a chat room.
        """
        room = self.get_object()
        message_text = request.data.get('message')

        if not message_text:
            return Response(
                {'detail': 'Сообщение не может быть пустым'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Sanitize message
        message_text = sanitize_text_input(message_text)

        # Create message
        message = ChatMessage.objects.create(
            room=room,
            sender=request.user,
            message=message_text
        )

        # Update room's updated_at
        room.save()

        # Send push notification to the other user
        recipient = room.ngo if request.user == room.volunteer else room.volunteer
        try:
            from .push_notifications import send_push_notification
            send_push_notification(
                recipient,
                f"Новое сообщение от {request.user.get_full_name() or request.user.username}",
                message_text[:100],
                data={
                    'type': 'chat_message',
                    'room_id': str(room.id),
                    'sender_id': str(request.user.id)
                }
            )
        except Exception as e:
            pass  # Don't fail if push notification fails

        serializer = ChatMessageSerializer(message)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """
        Get total unread message count for current user.
        """
        rooms = self.get_queryset()
        total_unread = 0

        for room in rooms:
            total_unread += room.messages.filter(
                is_read=False
            ).exclude(sender=request.user).count()

        return Response({'unread_count': total_unread})


class ChatMessageViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for viewing chat messages.
    """
    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        # Return messages from rooms where user is participant
        return ChatMessage.objects.filter(
            Q(room__volunteer=user) | Q(room__ngo=user)
        ).select_related('sender', 'room')
