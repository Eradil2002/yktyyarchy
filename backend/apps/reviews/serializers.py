from rest_framework import serializers
from .models import Review, Report
from apps.users.serializers import UserSerializer
from apps.users.sanitizers import sanitize_review_data
from apps.users.hateoas import add_review_links


class ReviewSerializer(serializers.ModelSerializer):
    reviewer_details = UserSerializer(source='reviewer', read_only=True)
    links = serializers.SerializerMethodField()

    class Meta:
        model = Review
        fields = '__all__'
        read_only_fields = ('reviewer', 'created_at')

    def get_links(self, obj):
        request = self.context.get('request')
        if request:
            return add_review_links(obj, request)
        return {}

    def validate(self, data):
        # Sanitize input data to prevent XSS
        data = sanitize_review_data(data)
        return data


class ReportSerializer(serializers.ModelSerializer):
    reporter_details = UserSerializer(source='reporter', read_only=True)
    content_type_name = serializers.SerializerMethodField()

    class Meta:
        model = Report
        fields = '__all__'
        read_only_fields = ('reporter', 'status', 'reviewed_by', 'reviewed_at', 'admin_notes', 'created_at')

    def get_content_type_name(self, obj):
        return obj.content_type.model

    def validate(self, data):
        # Sanitize description
        if 'description' in data:
            from apps.users.sanitizers import sanitize_text_input
            data['description'] = sanitize_text_input(data['description'])
        return data
