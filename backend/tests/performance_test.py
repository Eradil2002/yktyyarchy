"""
Performance tests using Locust.
Run with: locust -f tests/performance_test.py --host=http://localhost:8000
"""
from locust import HttpUser, task, between
import random


class VolunteerUser(HttpUser):
    """Simulate volunteer user behavior."""
    
    wait_time = between(1, 3)
    
    def on_start(self):
        """Login before starting tasks."""
        response = self.client.post("/api/v1/auth/login/", json={
            "username": "test_volunteer",
            "password": "testpass123"
        })
        if response.status_code == 200:
            self.token = response.json().get("access")
            self.client.headers.update({"Authorization": f"Bearer {self.token}"})
    
    @task(3)
    def list_events(self):
        """List events - most common operation."""
        self.client.get("/api/v1/events/")
    
    @task(2)
    def view_event_detail(self):
        """View event details."""
        event_id = random.randint(1, 100)
        self.client.get(f"/api/v1/events/{event_id}/")
    
    @task(1)
    def search_events(self):
        """Search events."""
        queries = ["ecology", "education", "health", "social"]
        query = random.choice(queries)
        self.client.get(f"/api/v1/events/?search={query}")
    
    @task(1)
    def view_profile(self):
        """View own profile."""
        self.client.get("/api/v1/users/profile/")
    
    @task(1)
    def list_notifications(self):
        """List notifications."""
        self.client.get("/api/v1/notifications/")


class NGOUser(HttpUser):
    """Simulate NGO user behavior."""
    
    wait_time = between(2, 5)
    
    def on_start(self):
        """Login before starting tasks."""
        response = self.client.post("/api/v1/auth/login/", json={
            "username": "test_ngo",
            "password": "testpass123"
        })
        if response.status_code == 200:
            self.token = response.json().get("access")
            self.client.headers.update({"Authorization": f"Bearer {self.token}"})
    
    @task(2)
    def list_own_events(self):
        """List own events."""
        self.client.get("/api/v1/events/my-events/")
    
    @task(1)
    def view_statistics(self):
        """View statistics."""
        self.client.get("/api/v1/events/statistics/")
    
    @task(1)
    def list_registrations(self):
        """List event registrations."""
        event_id = random.randint(1, 50)
        self.client.get(f"/api/v1/events/{event_id}/registrations/")
