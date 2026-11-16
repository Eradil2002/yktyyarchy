"""
Unit tests for user models.
"""
import pytest
from django.core.exceptions import ValidationError
from django.utils import timezone
from datetime import timedelta
from apps.users.models import CustomUser, VolunteerProfile, NGOProfile


@pytest.mark.django_db
class TestCustomUser:
    """Test CustomUser model."""

    def test_create_volunteer_user(self):
        """Test creating a volunteer user."""
        user = CustomUser.objects.create_user(
            username='volunteer1',
            email='volunteer1@test.com',
            password='testpass123',
            role='volunteer'
        )
        assert user.username == 'volunteer1'
        assert user.role == 'volunteer'
        assert user.total_hours == 0
        assert user.rating == 0.0
        assert not user.is_verified
        assert not user.email_verified

    def test_create_ngo_user(self):
        """Test creating an NGO user."""
        user = CustomUser.objects.create_user(
            username='ngo1',
            email='ngo1@test.com',
            password='testpass123',
            role='ngo'
        )
        assert user.role == 'ngo'

    def test_user_str_representation(self):
        """Test user string representation."""
        user = CustomUser.objects.create_user(
            username='testuser',
            first_name='Test',
            last_name='User',
            role='volunteer'
        )
        assert str(user) == 'Test User (volunteer)'

    def test_email_verification_code_valid(self):
        """Test email verification code validity check."""
        user = CustomUser.objects.create_user(
            username='test',
            email='test@test.com'
        )
        user.email_verification_code = '123456'
        user.email_verification_code_created = timezone.now()
        user.save()

        assert user.is_email_verification_code_valid()

    def test_email_verification_code_expired(self):
        """Test expired email verification code."""
        user = CustomUser.objects.create_user(
            username='test',
            email='test@test.com'
        )
        user.email_verification_code = '123456'
        user.email_verification_code_created = timezone.now() - timedelta(hours=25)
        user.save()

        assert not user.is_email_verification_code_valid()

    def test_unique_phone_constraint(self):
        """Test unique phone number constraint."""
        CustomUser.objects.create_user(
            username='user1',
            phone='+996555123456'
        )

        with pytest.raises(Exception):  # IntegrityError
            CustomUser.objects.create_user(
                username='user2',
                phone='+996555123456'
            )


@pytest.mark.django_db
class TestVolunteerProfile:
    """Test VolunteerProfile model."""

    def test_create_volunteer_profile(self):
        """Test creating volunteer profile."""
        user = CustomUser.objects.create_user(
            username='volunteer',
            role='volunteer'
        )
        profile = VolunteerProfile.objects.create(
            user=user,
            skills=['Python', 'Django'],
            bio='Test bio'
        )
        assert profile.user == user
        assert 'Python' in profile.skills
        assert profile.bio == 'Test bio'

    def test_volunteer_profile_str(self):
        """Test volunteer profile string representation."""
        user = CustomUser.objects.create_user(username='vol')
        profile = VolunteerProfile.objects.create(user=user)
        assert str(profile) == 'Волонтер: vol'


@pytest.mark.django_db
class TestNGOProfile:
    """Test NGOProfile model."""

    def test_create_ngo_profile(self):
        """Test creating NGO profile."""
        user = CustomUser.objects.create_user(
            username='ngo',
            role='ngo'
        )
        profile = NGOProfile.objects.create(
            user=user,
            org_name='Test NGO',
            description='Test description',
            contact_email='contact@ngo.com',
            website='https://ngo.com'
        )
        assert profile.user == user
        assert profile.org_name == 'Test NGO'
        assert profile.contact_email == 'contact@ngo.com'

    def test_ngo_profile_str(self):
        """Test NGO profile string representation."""
        user = CustomUser.objects.create_user(username='ngo')
        profile = NGOProfile.objects.create(user=user, org_name='My NGO')
        assert str(profile) == 'НКО: My NGO'
