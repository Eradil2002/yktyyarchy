"""
Unit tests for Event serializers.
"""
import pytest
from django.utils import timezone
from datetime import timedelta
from apps.events.models import Event, EventRegistration
from apps.events.serializers import EventSerializer, EventRegistrationSerializer


@pytest.mark.django_db
class TestEventSerializer:
    """Test EventSerializer."""

    def test_serialize_event(self, ngo_user):
        """Test serializing an event."""
        event = Event.objects.create(
            title='Test Event',
            description='Test description',
            organizer=ngo_user,
            category='ecology',
            date=timezone.now() + timedelta(days=7),
            location='Bishkek',
            latitude=42.8746,
            longitude=74.5698,
            type='offline',
            hours=4,
            spots_total=20,
            is_urgent=True
        )

        serializer = EventSerializer(event)
        data = serializer.data

        assert data['title'] == 'Test Event'
        assert data['description'] == 'Test description'
        assert data['category'] == 'ecology'
        assert data['type'] == 'offline'
        assert data['hours'] == 4
        assert data['spots_total'] == 20
        assert data['is_urgent'] is True
        assert 'organizer_details' in data

    def test_deserialize_event(self, ngo_user):
        """Test deserializing event data."""
        data = {
            'title': 'New Event',
            'description': 'New description',
            'category': 'education',
            'date': (timezone.now() + timedelta(days=5)).isoformat(),
            'location': 'Osh',
            'latitude': 40.5283,
            'longitude': 72.7985,
            'type': 'online',
            'hours': 3,
            'spots_total': 50
        }

        serializer = EventSerializer(data=data)
        assert serializer.is_valid(), serializer.errors

        event = serializer.save(organizer=ngo_user)
        assert event.title == 'New Event'
        assert event.category == 'education'
        assert event.type == 'online'

    def test_spots_booked_in_serializer(self, ngo_user, volunteer_user):
        """Test spots_booked field in serializer."""
        event = Event.objects.create(
            description='Test description',
            category='ecology',
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Test',
            hours=2,
            spots_total=10
        )

        EventRegistration.objects.create(event=event, volunteer=volunteer_user, status='approved')

        serializer = EventSerializer(event)
        assert serializer.data['spots_booked'] == 1

    def test_is_registered_field_authenticated(self, ngo_user, volunteer_user, api_client):
        """Test is_registered field for authenticated user."""
        event = Event.objects.create(
            description='Test description',
            category='ecology',
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Test',
            hours=2,
            spots_total=10
        )

        EventRegistration.objects.create(event=event, volunteer=volunteer_user, status='approved')

        # Mock request context
        from rest_framework.request import Request
        from django.test import RequestFactory
        factory = RequestFactory()
        request = factory.get('/')
        request.user = volunteer_user
        drf_request = Request(request)
        drf_request.user = volunteer_user

        serializer = EventSerializer(event, context={'request': drf_request})
        assert serializer.data['is_registered'] is True

    def test_is_registered_field_not_registered(self, ngo_user, volunteer_user, api_client):
        """Test is_registered field when user is not registered."""
        event = Event.objects.create(
            description='Test description',
            category='ecology',
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Test',
            hours=2,
            spots_total=10
        )

        from rest_framework.request import Request
        from django.test import RequestFactory
        factory = RequestFactory()
        request = factory.get('/')
        request.user = volunteer_user
        drf_request = Request(request)
        drf_request.user = volunteer_user

        serializer = EventSerializer(event, context={'request': drf_request})
        assert serializer.data['is_registered'] is False


@pytest.mark.django_db
class TestEventRegistrationSerializer:
    """Test EventRegistrationSerializer."""

    def test_serialize_registration(self, ngo_user, volunteer_user):
        """Test serializing an event registration."""
        event = Event.objects.create(
            description='Test description',
            category='ecology',
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Test',
            hours=2,
            spots_total=10
        )

        registration = EventRegistration.objects.create(
            event=event,
            volunteer=volunteer_user,
            status='approved'
        )

        serializer = EventRegistrationSerializer(registration)
        data = serializer.data

        assert data['status'] == 'approved'
        assert 'event' in data
        assert data['event']['title'] == 'Test Event'
