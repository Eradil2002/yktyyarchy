"""
Unit tests for Event and EventRegistration models.
"""
import pytest
from django.core.exceptions import ValidationError
from django.utils import timezone
from datetime import timedelta
from apps.events.models import Event, EventRegistration


@pytest.mark.django_db
class TestEventModel:
    """Test Event model."""

    def test_create_event(self, ngo_user):
        """Test creating a basic event."""
        event = Event.objects.create(
            title='Tree Planting',
            description='Plant trees in the park',
            organizer=ngo_user,
            category='ecology',
            date=timezone.now() + timedelta(days=7),
            location='Bishkek Park',
            latitude=42.8746,
            longitude=74.5698,
            type='offline',
            hours=4,
            spots_total=20
        )

        assert event.title == 'Tree Planting'
        assert event.organizer == ngo_user
        assert event.status == 'open'
        assert event.spots_booked == 0

    def test_event_str_representation(self, ngo_user):
        """Test event string representation."""
        event = Event.objects.create(
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Test Location',
            hours=2,
            spots_total=10
        )
        assert str(event) == 'Test Event'

    def test_latitude_validation_too_high(self, ngo_user):
        """Test latitude validation fails for values > 90."""
        with pytest.raises(ValidationError) as exc_info:
            event = Event(
                title='Invalid Event',
                organizer=ngo_user,
                date=timezone.now() + timedelta(days=1),
                location='Test',
                latitude=91.0,
                longitude=74.5698,
                hours=2,
                spots_total=10
            )
            event.save()

        assert 'latitude' in str(exc_info.value)

    def test_latitude_validation_too_low(self, ngo_user):
        """Test latitude validation fails for values < -90."""
        with pytest.raises(ValidationError) as exc_info:
            event = Event(
                title='Invalid Event',
                organizer=ngo_user,
                date=timezone.now() + timedelta(days=1),
                location='Test',
                latitude=-91.0,
                longitude=74.5698,
                hours=2,
                spots_total=10
            )
            event.save()

        assert 'latitude' in str(exc_info.value)

    def test_longitude_validation_too_high(self, ngo_user):
        """Test longitude validation fails for values > 180."""
        with pytest.raises(ValidationError) as exc_info:
            event = Event(
                title='Invalid Event',
                organizer=ngo_user,
                date=timezone.now() + timedelta(days=1),
                location='Test',
                latitude=42.8746,
                longitude=181.0,
                hours=2,
                spots_total=10
            )
            event.save()

        assert 'longitude' in str(exc_info.value)

    def test_longitude_validation_too_low(self, ngo_user):
        """Test longitude validation fails for values < -180."""
        with pytest.raises(ValidationError) as exc_info:
            event = Event(
                title='Invalid Event',
                organizer=ngo_user,
                date=timezone.now() + timedelta(days=1),
                location='Test',
                latitude=42.8746,
                longitude=-181.0,
                hours=2,
                spots_total=10
            )
            event.save()

        assert 'longitude' in str(exc_info.value)

    def test_spots_booked_property(self, ngo_user, volunteer_user):
        """Test spots_booked property counts approved registrations."""
        event = Event.objects.create(
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Test',
            hours=2,
            spots_total=10
        )

        # Create registrations with different statuses
        EventRegistration.objects.create(event=event, volunteer=volunteer_user, status='approved')

        # Create another user for second registration
        from django.contrib.auth import get_user_model
        User = get_user_model()
        user2 = User.objects.create_user(username='vol2', email='vol2@test.com', password='pass')
        EventRegistration.objects.create(event=event, volunteer=user2, status='pending')

        user3 = User.objects.create_user(username='vol3', email='vol3@test.com', password='pass')
        EventRegistration.objects.create(event=event, volunteer=user3, status='approved')

        # Only approved registrations should be counted
        assert event.spots_booked == 2

    def test_event_types(self, ngo_user):
        """Test event type choices."""
        online_event = Event.objects.create(
            title='Online Webinar',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Online',
            type='online',
            hours=2,
            spots_total=100
        )
        assert online_event.type == 'online'

        offline_event = Event.objects.create(
            title='Offline Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Bishkek',
            type='offline',
            hours=3,
            spots_total=50
        )
        assert offline_event.type == 'offline'

    def test_event_status_choices(self, ngo_user):
        """Test event status choices."""
        event = Event.objects.create(
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Test',
            hours=2,
            spots_total=10,
            status='open'
        )
        assert event.status == 'open'

        event.status = 'closed'
        event.save()
        assert event.status == 'closed'

        event.status = 'completed'
        event.save()
        assert event.status == 'completed'


@pytest.mark.django_db
class TestEventRegistrationModel:
    """Test EventRegistration model."""

    def test_create_registration(self, ngo_user, volunteer_user):
        """Test creating an event registration."""
        event = Event.objects.create(
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
            status='pending'
        )

        assert registration.event == event
        assert registration.volunteer == volunteer_user
        assert registration.status == 'pending'

    def test_registration_status_choices(self, ngo_user, volunteer_user):
        """Test registration status choices."""
        event = Event.objects.create(
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
            status='pending'
        )

        # Test all status transitions
        registration.status = 'approved'
        registration.save()
        assert registration.status == 'approved'

        registration.status = 'attended'
        registration.save()
        assert registration.status == 'attended'

        # Create new registration for rejected status
        from django.contrib.auth import get_user_model
        User = get_user_model()
        user2 = User.objects.create_user(username='vol2', email='vol2@test.com', password='pass')

        reg2 = EventRegistration.objects.create(
            event=event,
            volunteer=user2,
            status='pending'
        )
        reg2.status = 'rejected'
        reg2.save()
        assert reg2.status == 'rejected'

    def test_registration_str_representation(self, ngo_user, volunteer_user):
        """Test registration string representation."""
        event = Event.objects.create(
            title='Test Event',
            organizer=ngo_user,
            date=timezone.now() + timedelta(days=1),
            location='Test',
            hours=2,
            spots_total=10
        )

        registration = EventRegistration.objects.create(
            event=event,
            volunteer=volunteer_user
        )

        # Check that str contains both event and volunteer info
        str_repr = str(registration)
        assert 'Test Event' in str_repr or volunteer_user.username in str_repr
