"""
Basic tests for Reviews API.
"""
import pytest
from apps.events.models import Event, EventRegistration
from django.utils import timezone
from datetime import timedelta


@pytest.mark.django_db
@pytest.mark.integration
class TestReviewsAPI:
    """Test reviews endpoints."""

    def test_list_reviews(self, api_client):
        """Test listing reviews."""
        response = api_client.get('/api/v1/reviews/')
        assert response.status_code == 200

    def test_create_review_authenticated(self, authenticated_client, ngo_user, volunteer_user):
        """Test creating a review."""
        # Create event and registration
        event = Event.objects.create(
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() - timedelta(days=1),
            location='Test',
            hours=2,
            spots_total=10,
            status='completed'
        )
        EventRegistration.objects.create(
            event=event,
            volunteer=volunteer_user,
            status='attended'
        )

        data = {
            'event': event.id,
            'rating': 5,
            'comment': 'Great event!'
        }
        response = authenticated_client.post('/api/v1/reviews/', data, format='json')
        assert response.status_code in [200, 201]

    def test_create_review_unauthenticated(self, api_client):
        """Test creating review without authentication."""
        data = {
            'event': 1,
            'rating': 5,
            'comment': 'Test'
        }
        response = api_client.post('/api/v1/reviews/', data, format='json')
        assert response.status_code == 401
