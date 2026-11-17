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
        # role/email/phone/username must not be changed via profile update:
        # role -> privilege escalation; email/phone -> bypass of verification (phone is used for WhatsApp login)
        read_only_fields = ('total_hours', 'rating', 'is_verified', 'email_verified',
                            'role', 'email', 'phone', 'username')

    MAX_BIO_LEN = 1000
    MAX_SKILLS = 20
    MAX_SKILL_LEN = 50

    def get_links(self, obj):
        request = self.context.get('request')
        if request:
            return add_user_links(obj, request)
        return {}

    def _extract_profile_fields(self):
        """bio/skills come flat from the app (JSON or multipart), but live in VolunteerProfile."""
        data = self.initial_data
        out = {}
        if 'bio' in data:
            bio = str(data.get('bio') or '').strip()
            if len(bio) > self.MAX_BIO_LEN:
                raise serializers.ValidationError({'bio': f'Не более {self.MAX_BIO_LEN} символов.'})
            out['bio'] = bio
        skills = None
        if hasattr(data, 'getlist'):  # multipart / QueryDict
            for key in ('skills', 'skills[]'):
                if key in data:
                    skills = data.getlist(key)
        elif 'skills' in data:
            skills = data.get('skills')
        if skills is not None:
            if isinstance(skills, str):
                skills = [skills]
            if not isinstance(skills, list):
                raise serializers.ValidationError({'skills': 'Ожидается список.'})
            skills = [str(x).strip() for x in skills if str(x).strip()]
            skills = list(dict.fromkeys(skills))  # dedupe, keep order
            if len(skills) > self.MAX_SKILLS or any(len(x) > self.MAX_SKILL_LEN for x in skills):
                raise serializers.ValidationError({'skills': f'До {self.MAX_SKILLS} навыков, каждый до {self.MAX_SKILL_LEN} символов.'})
            out['skills'] = skills
        return out

    def update(self, instance, validated_data):
        profile_fields = self._extract_profile_fields()
        instance = super().update(instance, validated_data)
        if profile_fields and instance.role == 'volunteer':
            profile, _ = VolunteerProfile.objects.get_or_create(user=instance)
            for k, v in profile_fields.items():
                setattr(profile, k, v)
            profile.save()
        return instance


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
