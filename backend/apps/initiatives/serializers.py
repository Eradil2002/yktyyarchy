from rest_framework import serializers
from .models import Initiative
from apps.users.serializers import UserSerializer
from apps.users.sanitizers import sanitize_initiative_data
from apps.users.hateoas import add_initiative_links

class InitiativeSerializer(serializers.ModelSerializer):
    author_details = UserSerializer(source='author', read_only=True)
    hours = serializers.IntegerField(source='hours_claimed', read_only=True)
    creator = serializers.IntegerField(source='author.id', read_only=True)
    links = serializers.SerializerMethodField()

    class Meta:
        model = Initiative
        fields = '__all__'
        read_only_fields = ('author', 'status', 'created_at')

    def get_links(self, obj):
        request = self.context.get('request')
        if request:
            return add_initiative_links(obj, request)
        return {}

    def validate(self, data):
        # Sanitize input data to prevent XSS
        data = sanitize_initiative_data(data)
        return data
