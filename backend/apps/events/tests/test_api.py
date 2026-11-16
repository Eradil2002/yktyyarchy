"""
Integration tests for Events API endpoints.
"""
import pytest
from django.utils import timezone
from datetime import timedelta
from apps.events.models import Event, EventRegistration


@pytest.mark.django_db
@pytest.mark.integration
class TestEventListAPI:
    """Test GET /api/v1/events/ endpoint."""

    def test_list_events_unauthenticated(self, api_client, ngo_user):
        """Test listing events without authentication."""
        Event.objects.create(
            description='Test description',
            category='ecology',
            title='Public Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Bishkek',
            hours=2,
            spots_total=10
        )

        response = api_client.get('/api/v1/events/')
        assert response.status_code == 200
        assert 'results' in response.data
        assert len(response.data['results']) == 1

    def test_list_events_with_pagination(self, api_client, ngo_user):
        """Test events list pagination."""
        # Create multiple events
        for i in range(15):
            Event.objects.create(
                description='Test description',
                category='ecology',
                title=f'Event {i}',
                organizer=ngo_user,
                date=timezone.now() + timedelta(days=i+1),
                location='Bishkek',
                hours=2,
                spots_total=10
            )

        response = api_client.get('/api/v1/events/')
        assert response.status_code == 200
        assert 'results' in response.data
        assert 'next' in response.data or 'previous' in response.data

    def test_filter_events_by_category(self, api_client, ngo_user):
        """Test filtering events by category."""
        Event.objects.create(
            description='Test description',
            title='Ecology Event',
            organizer=ngo_user,
            category='ecology',
            date=timezone.now() + timedelta(days=1),
            location='Bishkek',
            hours=2,
            spots_total=10
        )
        Event.objects.create(
            description='Test description',
            title='Education Event',
            organizer=ngo_user,
            category='education',
            date=timezone.now() + timedelta(days=2),
            location='Bishkek',
            hours=2,
            spots_total=10
        )

        response = api_client.get('/api/v1/events/', {'category': 'ecology'})
        assert response.status_code == 200
        assert len(response.data['results']) == 1
        assert response.data['results'][0]['category'] == 'ecology'

    def test_filter_events_by_type(self, api_client, ngo_user):
        """Test filtering events by type."""
        Event.objects.create(
            description='Test description',
            category='ecology',
            title='Online Event',
            organizer=ngo_user,
            type='online',
            date=timezone.now() + timedelta(days=1),
            location='Online',
            hours=2,
            spots_total=10
        )
        Event.objects.create(
            description='Test description',
            category='ecology',
            title='Offline Event',
            organizer=ngo_user,
            type='offline',
            date=timezone.now() + timedelta(days=2),
            location='Bishkek',
            hours=2,
            spots_total=10
        )

        response = api_client.get('/api/v1/events/', {'type': 'online'})
        assert response.status_code == 200
        assert len(response.data['results']) == 1
        assert response.data['results'][0]['type'] == 'online'

    def test_filter_events_by_urgent(self, api_client, ngo_user):
        """Test filtering urgent events."""
        Event.objects.create(
            description='Test description',
            category='ecology',
            title='Urgent Event',
            organizer=ngo_user,
            is_urgent=True,
            date=timezone.now() + timedelta(days=1),
            location='Bishkek',
            hours=2,
            spots_total=10
        )
        Event.objects.create(
            description='Test description',
            category='ecology',
            title='Normal Event',
            organizer=ngo_user,
            is_urgent=False,
            date=timezone.now() + timedelta(days=2),
            location='Bishkek',
            hours=2,
            spots_total=10
        )

        response = api_client.get('/api/v1/events/', {'is_urgent': 'true'})
        assert response.status_code == 200
        assert len(response.data['results']) == 1
        assert response.data['results'][0]['is_urgent'] is True

    def test_search_events(self, api_client, ngo_user):
        """Test searching events by title."""
        Event.objects.create(
            description='Test description',
            category='ecology',
            title='Tree Planting Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Bishkek',
            hours=2,
            spots_total=10
        )
        Event.objects.create(
            description='Test description',
            category='ecology',
            title='Beach Cleanup',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=2),
            location='Issyk-Kul',
            hours=3,
            spots_total=15
        )

        response = api_client.get('/api/v1/events/', {'search': 'Tree'})
        assert response.status_code == 200
        assert len(response.data['results']) == 1
        assert 'Tree' in response.data['results'][0]['title']


@pytest.mark.django_db
@pytest.mark.integration
class TestEventCreateAPI:
    """Test POST /api/v1/events/ endpoint."""

    def test_create_event_as_ngo(self, ngo_authenticated_client, sample_event_data):
        """Test creating event as NGO user."""
        response = ngo_authenticated_client.post('/api/v1/events/', sample_event_data, format='json')
        assert response.status_code == 201
        assert response.data['title'] == sample_event_data['title']
        assert Event.objects.count() == 1

    def test_create_event_as_volunteer_forbidden(self, authenticated_client, sample_event_data):
        """Test volunteers cannot create events."""
        response = authenticated_client.post('/api/v1/events/', sample_event_data, format='json')
        assert response.status_code == 403

    def test_create_event_unauthenticated(self, api_client, sample_event_data):
        """Test creating event without authentication."""
        response = api_client.post('/api/v1/events/', sample_event_data, format='json')
        assert response.status_code == 401

    def test_create_event_invalid_data(self, ngo_authenticated_client):
        """Test creating event with invalid data."""
        invalid_data = {
            'title': '',  # Empty title
            'hours': -1,  # Negative hours
        }
        response = ngo_authenticated_client.post('/api/v1/events/', invalid_data, format='json')
        assert response.status_code == 400


@pytest.mark.django_db
@pytest.mark.integration
class TestEventDetailAPI:
    """Test GET /api/v1/events/{id}/ endpoint."""

    def test_get_event_detail(self, api_client, ngo_user):
        """Test retrieving event details."""
        event = Event.objects.create(
            description='Test description',
            category='ecology',
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Bishkek',
            hours=2,
            spots_total=10
        )

        response = api_client.get(f'/api/v1/events/{event.id}/')
        assert response.status_code == 200
        assert response.data['title'] == 'Test Event'

    def test_get_nonexistent_event(self, api_client):
        """Test retrieving non-existent event."""
        response = api_client.get('/api/v1/events/99999/')
        assert response.status_code == 404


@pytest.mark.django_db
@pytest.mark.integration
class TestEventUpdateAPI:
    """Test PUT/PATCH /api/v1/events/{id}/ endpoint."""

    def test_update_event_as_organizer(self, ngo_authenticated_client, ngo_user):
        """Test updating event as organizer."""
        event = Event.objects.create(
            description='Test description',
            category='ecology',
            title='Original Title',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Bishkek',
            hours=2,
            spots_total=10
        )

        update_data = {'title': 'Updated Title'}
        response = ngo_authenticated_client.patch(f'/api/v1/events/{event.id}/', update_data, format='json')
        assert response.status_code == 200
        assert response.data['title'] == 'Updated Title'

    def test_update_event_as_different_ngo(self, api_client, ngo_user):
        """Test updating event as different NGO."""
        event = Event.objects.create(
            description='Test description',
            category='ecology',
            title='Original Title',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Bishkek',
            hours=2,
            spots_total=10
        )

        # Create different NGO user
        from django.contrib.auth import get_user_model
        User = get_user_model()
        other_ngo = User.objects.create_user(
            username='other_ngo',
            email='other@test.com',
            password='pass',
            role='ngo'
        )
        api_client.force_authenticate(user=other_ngo)

        update_data = {'title': 'Hacked Title'}
        response = api_client.patch(f'/api/v1/events/{event.id}/', update_data, format='json')
        assert response.status_code == 403


@pytest.mark.django_db
@pytest.mark.integration
class TestEventDeleteAPI:
    """Test DELETE /api/v1/events/{id}/ endpoint."""

    def test_delete_event_as_organizer(self, ngo_authenticated_client, ngo_user):
        """Test deleting event as organizer."""
        event = Event.objects.create(
            description='Test description',
            category='ecology',
            title='To Delete',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Bishkek',
            hours=2,
            spots_total=10
        )

        response = ngo_authenticated_client.delete(f'/api/v1/events/{event.id}/')
        assert response.status_code == 204
        assert Event.objects.filter(id=event.id, deleted_at__isnull=True).count() == 0
