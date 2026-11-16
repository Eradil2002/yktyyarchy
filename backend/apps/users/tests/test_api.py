"""
Integration tests for User Authentication API.
"""
import pytest
from django.contrib.auth import get_user_model
from django.utils import timezone
from datetime import timedelta

User = get_user_model()


@pytest.mark.django_db
@pytest.mark.integration
class TestRegisterAPI:
    """Test POST /api/v1/auth/register/ endpoint."""

    def test_register_volunteer_success(self, api_client):
        """Test successful volunteer registration."""
        data = {
            'username': 'newvolunteer',
            'email': 'volunteer@example.com',
            'password': 'SecurePass123!',
            'password2': 'SecurePass123!',
            'first_name': 'John',
            'last_name': 'Doe',
            'role': 'volunteer'
        }

        response = api_client.post('/api/v1/auth/register/', data, format='json')
        assert response.status_code == 201
        assert 'access' in response.data
        assert 'refresh' in response.data
        assert User.objects.filter(username='newvolunteer').exists()

    def test_register_ngo_success(self, api_client):
        """Test successful NGO registration."""
        data = {
            'username': 'newngo',
            'email': 'ngo@example.com',
            'password': 'SecurePass123!',
            'password2': 'SecurePass123!',
            'first_name': 'Green',
            'last_name': 'NGO',
            'role': 'ngo'
        }

        response = api_client.post('/api/v1/auth/register/', data, format='json')
        assert response.status_code == 201
        user = User.objects.get(username='newngo')
        assert user.role == 'ngo'

    def test_register_password_mismatch(self, api_client):
        """Test registration with mismatched passwords."""
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'SecurePass123!',
            'password2': 'DifferentPass123!',
            'first_name': 'Test',
            'last_name': 'User',
            'role': 'volunteer'
        }

        response = api_client.post('/api/v1/auth/register/', data, format='json')
        assert response.status_code == 400

    def test_register_duplicate_username(self, api_client, volunteer_user):
        """Test registration with existing username."""
        data = {
            'username': volunteer_user.username,
            'email': 'newemail@example.com',
            'password': 'SecurePass123!',
            'password2': 'SecurePass123!',
            'first_name': 'Test',
            'last_name': 'User',
            'role': 'volunteer'
        }

        response = api_client.post('/api/v1/auth/register/', data, format='json')
        assert response.status_code == 400

    def test_register_duplicate_email(self, api_client, volunteer_user):
        """Test registration with existing email."""
        data = {
            'username': 'newusername',
            'email': volunteer_user.email,
            'password': 'SecurePass123!',
            'password2': 'SecurePass123!',
            'first_name': 'Test',
            'last_name': 'User',
            'role': 'volunteer'
        }

        response = api_client.post('/api/v1/auth/register/', data, format='json')
        assert response.status_code == 400

    def test_register_weak_password(self, api_client):
        """Test registration with weak password."""
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': '123',
            'password2': '123',
            'first_name': 'Test',
            'last_name': 'User',
            'role': 'volunteer'
        }

        response = api_client.post('/api/v1/auth/register/', data, format='json')
        assert response.status_code == 400


@pytest.mark.django_db
@pytest.mark.integration
class TestLoginAPI:
    """Test POST /api/v1/auth/login/ endpoint."""

    def test_login_success(self, api_client, volunteer_user):
        """Test successful login."""
        data = {
            'username': volunteer_user.username,
            'password': 'testpass123'
        }

        response = api_client.post('/api/v1/auth/login/', data, format='json')
        assert response.status_code == 200
        assert 'access' in response.data
        assert 'refresh' in response.data

    def test_login_wrong_password(self, api_client, volunteer_user):
        """Test login with wrong password."""
        data = {
            'username': volunteer_user.username,
            'password': 'wrongpassword'
        }

        response = api_client.post('/api/v1/auth/login/', data, format='json')
        assert response.status_code in [400, 401]

    def test_login_nonexistent_user(self, api_client):
        """Test login with non-existent user."""
        data = {
            'username': 'nonexistent',
            'password': 'somepassword'
        }

        response = api_client.post('/api/v1/auth/login/', data, format='json')
        assert response.status_code in [400, 401]


@pytest.mark.django_db
@pytest.mark.integration
class TestEmailVerificationAPI:
    """Test POST /api/v1/auth/verify-email/ endpoint."""

    def test_verify_email_success(self, authenticated_client, volunteer_user):
        """Test successful email verification."""
        # Set verification code
        volunteer_user.email_verified = False
        volunteer_user.email_verification_code = '123456'
        volunteer_user.email_verification_code_created = timezone.now()
        volunteer_user.save()

        data = {'code': '123456'}
        response = authenticated_client.post('/api/v1/auth/verify-email/', data, format='json')
        assert response.status_code == 200

        volunteer_user.refresh_from_db()
        assert volunteer_user.email_verified is True

    def test_verify_email_wrong_code(self, authenticated_client, volunteer_user):
        """Test email verification with wrong code."""
        volunteer_user.email_verified = False
        volunteer_user.email_verification_code = '123456'
        volunteer_user.email_verification_code_created = timezone.now()
        volunteer_user.save()

        data = {'code': '999999'}
        response = authenticated_client.post('/api/v1/auth/verify-email/', data, format='json')
        assert response.status_code == 400

    def test_verify_email_expired_code(self, authenticated_client, volunteer_user):
        """Test email verification with expired code."""
        volunteer_user.email_verified = False
        volunteer_user.email_verification_code = '123456'
        volunteer_user.email_verification_code_created = timezone.now() - timedelta(hours=25)
        volunteer_user.save()

        data = {'code': '123456'}
        response = authenticated_client.post('/api/v1/auth/verify-email/', data, format='json')
        assert response.status_code == 400

    def test_verify_email_already_verified(self, authenticated_client, volunteer_user):
        """Test verifying already verified email."""
        volunteer_user.email_verified = True
        volunteer_user.save()

        data = {'code': '123456'}
        response = authenticated_client.post('/api/v1/auth/verify-email/', data, format='json')
        assert response.status_code == 400


@pytest.mark.django_db
@pytest.mark.integration
class TestUserProfileAPI:
    """Test user profile endpoints."""

    def test_get_own_profile(self, authenticated_client, volunteer_user):
        """Test getting own user profile."""
        response = authenticated_client.get('/api/v1/users/me/')
        assert response.status_code == 200
        assert response.data['username'] == volunteer_user.username

    def test_update_own_profile(self, authenticated_client, volunteer_user):
        """Test updating own profile."""
        data = {
            'first_name': 'Updated',
            'last_name': 'Name'
        }
        response = authenticated_client.patch('/api/v1/users/me/', data, format='json')
        assert response.status_code == 200
        assert response.data['first_name'] == 'Updated'

    def test_get_profile_unauthenticated(self, api_client):
        """Test getting profile without authentication."""
        response = api_client.get('/api/v1/users/me/')
        assert response.status_code == 401
