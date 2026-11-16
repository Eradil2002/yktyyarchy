"""
Basic tests for Initiatives API.
"""
import pytest
from django.utils import timezone
from datetime import timedelta


@pytest.mark.django_db
@pytest.mark.integration
class TestInitiativesAPI:
    """Test initiatives endpoints."""

    def test_list_initiatives(self, api_client):
        """Test listing initiatives."""
        response = api_client.get('/api/v1/initiatives/')
        assert response.status_code == 200

    def test_create_initiative_as_ngo(self, ngo_authenticated_client):
        """Test creating initiative as NGO."""
        data = {
            'title': 'New Initiative',
            'description': 'Test description',
            'category': 'ecology',
            'start_date': (timezone.now() + timedelta(days=1)).isoformat(),
            'end_date': (timezone.now() + timedelta(days=30)).isoformat(),
        }
        response = ngo_authenticated_client.post('/api/v1/initiatives/', data, format='json')
        assert response.status_code in [200, 201]

    def test_create_initiative_as_volunteer_forbidden(self, authenticated_client):
        """Test volunteers cannot create initiatives."""
        data = {
            'title': 'New Initiative',
            'description': 'Test description',
        }
        response = authenticated_client.post('/api/v1/initiatives/', data, format='json')
        assert response.status_code == 403
