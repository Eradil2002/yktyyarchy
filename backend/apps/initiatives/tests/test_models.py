"""
Unit tests for initiative models.
"""
import pytest
from django.core.exceptions import ValidationError
from apps.initiatives.models import Initiative


@pytest.mark.django_db
class TestInitiative:
    """Test Initiative model."""

    def test_create_initiative(self, volunteer_user):
        """Test creating an initiative."""
        initiative = Initiative.objects.create(
            title='Clean Park',
            description='Cleaning local park',
            author=volunteer_user,
            category='ecology',
            location='Bishkek Park',
            latitude=42.8746,
            longitude=74.5698,
            hours_claimed=3,
            status='pending'
        )
        assert initiative.title == 'Clean Park'
        assert initiative.author == volunteer_user
        assert initiative.status == 'pending'

    def test_initiative_str(self, volunteer_user):
        """Test initiative string representation."""
        initiative = Initiative.objects.create(
            title='My Initiative',
            description='Test',
            author=volunteer_user,
            category='ecology',
            location='Test',
            hours_claimed=2
        )
        assert str(initiative) == f"My Initiative by {volunteer_user.username}"

    def test_initiative_latitude_validation(self, volunteer_user):
        """Test latitude validation."""
        with pytest.raises(ValidationError) as exc_info:
            initiative = Initiative(
                title='Test',
                description='Test',
                author=volunteer_user,
                category='ecology',
                location='Test',
                latitude=100,  # Invalid
                longitude=74.5698,
                hours_claimed=2
            )
            initiative.save()
        assert 'latitude' in str(exc_info.value)

    def test_initiative_longitude_validation(self, volunteer_user):
        """Test longitude validation."""
        with pytest.raises(ValidationError) as exc_info:
            initiative = Initiative(
                title='Test',
                description='Test',
                author=volunteer_user,
                category='ecology',
                location='Test',
                latitude=42.8746,
                longitude=200,  # Invalid
                hours_claimed=2
            )
            initiative.save()
        assert 'longitude' in str(exc_info.value)
