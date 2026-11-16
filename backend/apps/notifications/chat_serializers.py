from rest_framework import serializers
from .models import ChatRoom, ChatMessage
from apps.users.serializers import UserSerializer


class ChatMessageSerializer(serializers.ModelSerializer):
    sender_details = UserSerializer(source='sender', read_only=True)

    class Meta:
        model = ChatMessage
        fields = ['id', 'room', 'sender', 'sender_details', 'message', 'is_read', 'created_at']
        read_only_fields = ['sender', 'created_at']


class ChatRoomSerializer(serializers.ModelSerializer):
    volunteer_details = UserSerializer(source='volunteer', read_only=True)
    ngo_details = UserSerializer(source='ngo', read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = ['id', 'event', 'volunteer', 'volunteer_details', 'ngo', 'ngo_details',
                  'created_at', 'updated_at', 'last_message', 'unread_count']
        read_only_fields = ['created_at', 'updated_at']

    def get_last_message(self, obj):
        last_msg = obj.messages.last()
        if last_msg:
            return {
                'message': last_msg.message,
                'sender': last_msg.sender.username,
                'created_at': last_msg.created_at
            }
        return None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if request and request.user:
            return obj.messages.filter(is_read=False).exclude(sender=request.user).count()
        return 0
