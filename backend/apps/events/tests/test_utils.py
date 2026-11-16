"""
Unit tests for event utility functions.
"""
import pytest
from apps.events.views import haversine


class TestHaversineFunction:
    """Test haversine distance calculation."""

    def test_haversine_same_location(self):
        """Test distance between same coordinates is 0."""
        distance = haversine(42.8746, 74.5698, 42.8746, 74.5698)
        assert distance < 0.01  # Should be very close to 0

    def test_haversine_known_distance(self):
        """Test haversine with known distance."""
        # Bishkek to Osh (approximate)
        bishkek_lat, bishkek_lon = 42.8746, 74.5698
        osh_lat, osh_lon = 40.5283, 72.7985

        distance = haversine(bishkek_lat, bishkek_lon, osh_lat, osh_lon)

        # Great-circle distance Bishkek-Osh is ~300 km (road is ~600 km)
        assert 280 < distance < 320

    def test_haversine_with_none_values(self):
        """Test haversine returns infinity for None values."""
        assert haversine(None, 74.5698, 42.8746, 74.5698) == float('inf')
        assert haversine(42.8746, None, 42.8746, 74.5698) == float('inf')
        assert haversine(42.8746, 74.5698, None, 74.5698) == float('inf')
        assert haversine(42.8746, 74.5698, 42.8746, None) == float('inf')

    def test_haversine_symmetry(self):
        """Test that distance A->B equals distance B->A."""
        lat1, lon1 = 42.8746, 74.5698
        lat2, lon2 = 40.5283, 72.7985

        distance_ab = haversine(lat1, lon1, lat2, lon2)
        distance_ba = haversine(lat2, lon2, lat1, lon1)

        assert abs(distance_ab - distance_ba) < 0.01

    def test_haversine_positive_result(self):
        """Test that haversine always returns positive distance."""
        distance = haversine(42.8746, 74.5698, 40.5283, 72.7985)
        assert distance > 0
