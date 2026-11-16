"""
Unit tests for review models.
"""
import pytest
from django.contrib.contenttypes.models import ContentType
from apps.reviews.models import Review, Report
from apps.events.models import Event
from django.utils import timezone
from datetime import timedelta


@pytest.mark.django_db
class TestReview:
    """Test Review model."""

    def test_create_review(self, ngo_user, volunteer_user):
        """Test creating a review."""
        event = Event.objects.create(
            title='Test Event',
            description='Test',
            organizer=ngo_user,
            category='ecology',
            date=timezone.now() + timedelta(days=7),
            location='Bishkek',
            hours=4,
            spots_total=20
        )
        
        review = Review.objects.create(
            reviewer=ngo_user,
            target_user=volunteer_user,
            event=event,
            rating=5,
            text='Great volunteer!',
            is_from_ngo=True
        )
        
        assert review.reviewer == ngo_user
        assert review.target_user == volunteer_user
        assert review.rating == 5
        assert review.moderation_status == 'approved'

    def test_review_str(self, ngo_user, volunteer_user):
        """Test review string representation."""
        review = Review.objects.create(
            reviewer=ngo_user,
            target_user=volunteer_user,
            rating=4,
            text='Good work'
        )
        
        assert str(review) == f"{ngo_user.username} -> {volunteer_user.username} (4 stars)"


@pytest.mark.django_db
class TestReport:
    """Test Report model."""

    def test_create_report(self, volunteer_user, ngo_user):
        """Test creating a report."""
        event = Event.objects.create(
            title='Test Event',
            description='Test',
            organizer=ngo_user,
            category='ecology',
            date=timezone.now() + timedelta(days=7),
            location='Bishkek',
            hours=4,
            spots_total=20
        )
        
        content_type = ContentType.objects.get_for_model(Event)
        
        report = Report.objects.create(
            reporter=volunteer_user,
            content_type=content_type,
            object_id=event.id,
            report_type='spam',
            description='This is spam',
            status='pending'
        )
        
        assert report.reporter == volunteer_user
        assert report.content_object == event
        assert report.report_type == 'spam'
        assert report.status == 'pending'

    def test_report_str(self, volunteer_user, ngo_user):
        """Test report string representation."""
        event = Event.objects.create(
            title='Test',
            description='Test',
            organizer=ngo_user,
            category='ecology',
            date=timezone.now() + timedelta(days=1),
            location='Test',
            hours=2,
            spots_total=10
        )
        
        content_type = ContentType.objects.get_for_model(Event)
        
        report = Report.objects.create(
            reporter=volunteer_user,
            content_type=content_type,
            object_id=event.id,
            report_type='fake',
            description='Fake event'
        )
        
        assert str(report) == f"Report by {volunteer_user.username} - fake (pending)"
