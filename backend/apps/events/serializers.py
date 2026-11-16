from rest_framework import serializers
from .models import Event, EventRegistration
from apps.users.serializers import UserSerializer
from apps.users.sanitizers import sanitize_event_data
from apps.users.hateoas import add_event_links

class EventSerializer(serializers.ModelSerializer):
    organizer_details = UserSerializer(source='organizer', read_only=True)
    spots_booked = serializers.IntegerField(read_only=True)
    is_registered = serializers.SerializerMethodField()
    links = serializers.SerializerMethodField()

    class Meta:
        model = Event
        fields = '__all__'
        read_only_fields = ('organizer', 'status', 'created_at')

    def get_is_registered(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return EventRegistration.objects.filter(event=obj, volunteer=request.user).exists()
        return False

    def get_links(self, obj):
        request = self.context.get('request')
        if request:
            return add_event_links(obj, request)
        return {}

    def validate(self, data):
        # Sanitize input data to prevent XSS
        data = sanitize_event_data(data)
        return data


class EventRegistrationSerializer(serializers.ModelSerializer):
    event = EventSerializer(read_only=True)
    links = serializers.SerializerMethodField()

    class Meta:
        model = EventRegistration
        fields = '__all__'
        read_only_fields = ('volunteer', 'status', 'registered_at')

    def get_links(self, obj):
        from apps.users.hateoas import add_registration_links
        request = self.context.get('request')
        if request:
            return add_registration_links(obj, request)
        return {}
