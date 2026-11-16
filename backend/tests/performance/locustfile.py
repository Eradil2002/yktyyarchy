"""
Performance tests for Volunteering Platform API using Locust.

Run with: locust -f locustfile.py --host=http://localhost:8000
"""
from locust import HttpUser, task, between
import random


class VolunteerUser(HttpUser):
    """Simulates a volunteer user browsing events."""

    wait_time = between(1, 3)  # Wait 1-3 seconds between tasks

    def on_start(self):
        """Called when a user starts. Perform login."""
        # Register or login
        self.client.post("/api/v1/auth/login/", json={
            "username": f"testuser_{random.randint(1, 1000)}",
            "password": "testpass123"
        }, name="/api/v1/auth/login/ [POST]")

    @task(5)
    def list_events(self):
        """List events - most common operation."""
        self.client.get("/api/v1/events/", name="/api/v1/events/ [GET]")

    @task(3)
    def list_events_with_filter(self):
        """List events with category filter."""
        categories = ['ecology', 'education', 'health', 'social']
        category = random.choice(categories)
        self.client.get(
            f"/api/v1/events/?category={category}",
            name="/api/v1/events/?category=X [GET]"
        )

    @task(2)
    def view_event_detail(self):
        """View event details."""
        event_id = random.randint(1, 100)
        self.client.get(
            f"/api/v1/events/{event_id}/",
            name="/api/v1/events/{id}/ [GET]"
        )

    @task(1)
    def search_events(self):
        """Search events."""
        search_terms = ['tree', 'clean', 'teach', 'help', 'volunteer']
        term = random.choice(search_terms)
        self.client.get(
            f"/api/v1/events/?search={term}",
            name="/api/v1/events/?search=X [GET]"
        )

    @task(1)
    def list_initiatives(self):
        """List initiatives."""
        self.client.get("/api/v1/initiatives/", name="/api/v1/initiatives/ [GET]")

    @task(1)
    def get_user_profile(self):
        """Get user profile."""
        self.client.get("/api/v1/users/me/", name="/api/v1/users/me/ [GET]")


class NGOUser(HttpUser):
    """Simulates an NGO user managing events."""

    wait_time = between(2, 5)

    def on_start(self):
        """Login as NGO."""
        response = self.client.post("/api/v1/auth/login/", json={
            "username": f"ngo_{random.randint(1, 100)}",
            "password": "testpass123"
        }, name="/api/v1/auth/login/ [POST]")

        if response.status_code == 200:
            self.token = response.json().get('access')

    @task(3)
    def list_own_events(self):
        """List own events."""
        self.client.get("/api/v1/events/", name="/api/v1/events/ [GET]")

    @task(2)
    def view_event_statistics(self):
        """View event statistics."""
        event_id = random.randint(1, 50)
        self.client.get(
            f"/api/v1/events/{event_id}/statistics/",
            name="/api/v1/events/{id}/statistics/ [GET]"
        )

    @task(1)
    def create_event(self):
        """Create a new event."""
        from datetime import datetime, timedelta

        event_data = {
            "title": f"Test Event {random.randint(1, 10000)}",
            "description": "Performance test event",
            "category": random.choice(['ecology', 'education', 'health']),
            "date": (datetime.now() + timedelta(days=random.randint(1, 30))).isoformat(),
            "location": "Bishkek",
            "latitude": 42.8746,
            "longitude": 74.5698,
            "type": "offline",
            "hours": random.randint(2, 8),
            "spots_total": random.randint(10, 50)
        }

        self.client.post(
            "/api/v1/events/",
            json=event_data,
            name="/api/v1/events/ [POST]"
        )

    @task(1)
    def list_registrations(self):
        """List event registrations."""
        self.client.get(
            "/api/v1/registrations/",
            name="/api/v1/registrations/ [GET]"
        )


class AnonymousUser(HttpUser):
    """Simulates anonymous user browsing."""

    wait_time = between(1, 4)

    @task(10)
    def browse_events(self):
        """Browse events without authentication."""
        self.client.get("/api/v1/events/", name="/api/v1/events/ [GET]")

    @task(5)
    def view_event_detail(self):
        """View event details."""
        event_id = random.randint(1, 100)
        self.client.get(
            f"/api/v1/events/{event_id}/",
            name="/api/v1/events/{id}/ [GET]"
        )

    @task(3)
    def browse_initiatives(self):
        """Browse initiatives."""
        self.client.get("/api/v1/initiatives/", name="/api/v1/initiatives/ [GET]")

    @task(1)
    def view_ngo_profile(self):
        """View NGO profile."""
        ngo_id = random.randint(1, 50)
        self.client.get(
            f"/api/v1/users/{ngo_id}/",
            name="/api/v1/users/{id}/ [GET]"
        )
