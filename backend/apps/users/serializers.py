from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import CustomUser, VolunteerProfile, NGOProfile
from .sanitizers import sanitize_user_profile_data
from .hateoas import add_user_links

class VolunteerProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = VolunteerProfile
        fields = ('skills', 'bio')


class NGOProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = NGOProfile
        fields = ('org_name', 'description', 'contact_email', 'website')


class UserSerializer(serializers.ModelSerializer):
    volunteer_profile = VolunteerProfileSerializer(read_only=True)
    ngo_profile = NGOProfileSerializer(read_only=True)
    links = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = ('id', 'username', 'email', 'phone', 'first_name', 'last_name',
                  'role', 'avatar', 'location', 'total_hours', 'rating', 'is_verified',
                  'email_verified', 'volunteer_profile', 'ngo_profile', 'links')
        read_only_fields = ('total_hours', 'rating', 'is_verified', 'email_verified')

    def get_links(self, obj):
        request = self.context.get('request')
        if request:
            return add_user_links(obj, request)
        return {}


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)
    role = serializers.ChoiceField(choices=CustomUser.ROLE_CHOICES)
    org_name = serializers.CharField(required=False, write_only=True)

    class Meta:
        model = CustomUser
        fields = ('username', 'email', 'password', 'password_confirm', 'phone',
                  'first_name', 'last_name', 'role', 'org_name')

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({"password": "Пароли не совпадают."})

        if data.get('role') == 'ngo' and not data.get('org_name'):
            raise serializers.ValidationError({"org_name": "Укажите название организации для роли НКО."})

        return data

    def validate_username(self, value):
        """
        Check username uniqueness with generic error message to prevent enumeration
        """
        if CustomUser.objects.filter(username=value).exists():
            raise serializers.ValidationError("Это имя пользователя недоступно.")
        return value

    def validate_email(self, value):
        """
        Check email uniqueness with generic error message to prevent enumeration
        """
        if CustomUser.objects.filter(email=value).exists():
            raise serializers.ValidationError("Этот email недоступен.")
        return value

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        org_name = validated_data.pop('org_name', None)

        # Sanitize user input data
        validated_data = sanitize_user_profile_data(validated_data)
        if org_name:
            org_name = sanitize_user_profile_data({'org_name': org_name})['org_name']

        user = CustomUser.objects.create_user(**validated_data)

        if user.role == 'volunteer':
            VolunteerProfile.objects.create(user=user)
        elif user.role == 'ngo':
            NGOProfile.objects.create(user=user, org_name=org_name)

        return user


class EmailVerificationSerializer(serializers.Serializer):
    code = serializers.CharField(max_length=6, min_length=6)

class WhatsAppOTPRequestSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)


class WhatsAppOTPVerifySerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    code = serializers.CharField(max_length=6, min_length=6)


class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()


class PasswordResetConfirmSerializer(serializers.Serializer):
    uid = serializers.CharField()
    token = serializers.CharField()
    new_password = serializers.CharField(write_only=True, validators=[validate_password])
    new_password_confirm = serializers.CharField(write_only=True)

    def validate(self, data):
        if data['new_password'] != data['new_password_confirm']:
            raise serializers.ValidationError({"new_password": "Пароли не совпадают."})
        return data
