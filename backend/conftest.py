"""
Pytest configuration and fixtures for Django tests.
"""
import pytest
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient

User = get_user_model()


@pytest.fixture
def api_client():
    """Return DRF API client."""
    return APIClient()


@pytest.fixture
def volunteer_user(db):
    """Create a volunteer user."""
    return User.objects.create_user(
        username='volunteer_test',
        email='volunteer@test.com',
        password='testpass123',
        first_name='Test',
        last_name='Volunteer',
        role='volunteer',
        email_verified=True
    )


@pytest.fixture
def ngo_user(db):
    """Create an NGO user."""
    return User.objects.create_user(
        username='ngo_test',
        email='ngo@test.com',
        password='testpass123',
        first_name='Test',
        last_name='NGO',
        role='ngo',
        email_verified=True,
        is_verified=True
    )


@pytest.fixture
def authenticated_client(api_client, volunteer_user):
    """Return authenticated API client with volunteer user."""
    api_client.force_authenticate(user=volunteer_user)
    return api_client


@pytest.fixture
def ngo_authenticated_client(api_client, ngo_user):
    """Return authenticated API client with NGO user."""
    api_client.force_authenticate(user=ngo_user)
    return api_client


@pytest.fixture
def sample_event_data():
    """Return sample event data for testing."""
    from django.utils import timezone
    from datetime import timedelta

    return {
        'title': 'Test Event',
        'description': 'Test event description',
        'category': 'ecology',
        'date': timezone.now() + timedelta(days=7),
        'location': 'Bishkek, Test Location',
        'latitude': 42.8746,
        'longitude': 74.5698,
        'type': 'offline',
        'hours': 4,
        'spots_total': 20,
        'status': 'open',
        'is_urgent': False
    }
