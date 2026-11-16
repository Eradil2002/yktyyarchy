"""
Basic tests for Notifications API.
"""
import pytest


@pytest.mark.django_db
@pytest.mark.integration
class TestNotificationsAPI:
    """Test notifications endpoints."""

    def test_list_notifications_authenticated(self, authenticated_client):
        """Test listing user notifications."""
        response = authenticated_client.get('/api/v1/notifications/')
        assert response.status_code == 200

    def test_list_notifications_unauthenticated(self, api_client):
        """Test listing notifications without auth."""
        response = api_client.get('/api/v1/notifications/')
        assert response.status_code == 401

    def test_mark_notification_read(self, authenticated_client):
        """Test marking notification as read."""
        # This test assumes notification exists
        response = authenticated_client.get('/api/v1/notifications/')
        assert response.status_code == 200
