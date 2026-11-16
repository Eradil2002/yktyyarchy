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
            description='Test description',
            category='ecology',
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

        from django.contrib.auth import get_user_model
        teammate = get_user_model().objects.create_user(username='teammate', email='tm@test.com', password='pass', role='volunteer')
        EventRegistration.objects.create(event=event, volunteer=teammate, status='attended')

        data = {
            'target_user': teammate.id,
            'event': event.id,
            'rating': 5,
            'text': 'Great teammate!'
        }
        response = authenticated_client.post('/api/v1/reviews/', data, format='json')
        assert response.status_code == 201, response.data
        assert response.data['moderation_status'] == 'approved'

    def test_cannot_edit_others_review(self, authenticated_client, volunteer_user, ngo_user):
        """IDOR guard: a user cannot modify someone else's review."""
        from apps.reviews.models import Review
        from django.contrib.auth import get_user_model
        U = get_user_model()
        a = U.objects.create_user(username='a1', email='a1@t.com', password='p', role='volunteer')
        b = U.objects.create_user(username='b1', email='b1@t.com', password='p', role='volunteer')
        review = Review.objects.create(reviewer=a, target_user=b, rating=5, text='ok')
        response = authenticated_client.patch(f'/api/v1/reviews/{review.id}/', {'rating': 1}, format='json')
        assert response.status_code in (403, 404)

    def test_create_review_unauthenticated(self, api_client):
        """Test creating review without authentication."""
        data = {
            'target_user': 1,
            'rating': 5,
            'text': 'Test'
        }
        response = api_client.post('/api/v1/reviews/', data, format='json')
        assert response.status_code == 401
