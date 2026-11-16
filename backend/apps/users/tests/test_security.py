"""Regression tests for security fixes (reset-link poisoning, JWT revoke, IDOR)."""
import pytest
from django.core import mail
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth import get_user_model

from apps.events.models import Event
from apps.initiatives.models import Initiative

User = get_user_model()


@pytest.mark.django_db
class TestPasswordResetPoisoning:
    def test_client_reset_url_is_ignored(self, api_client, volunteer_user, settings):
        settings.EMAIL_BACKEND = 'django.core.mail.backends.locmem.EmailBackend'
        settings.FRONTEND_URL = 'https://app.example.kg'
        api_client.post('/api/v1/users/auth/password-reset/',
                        {'email': volunteer_user.email, 'reset_url': 'https://evil.com/steal'}, format='json')
        assert len(mail.outbox) == 1
        body = mail.outbox[0].body
        assert 'evil.com' not in body
        assert 'https://app.example.kg/#/reset-password?uid=' in body


@pytest.mark.django_db
class TestJWTRevocation:
    def _login(self, api_client):
        User.objects.create_user(username='jwtuser', email='jwt@t.com', password='Pass12345!x', role='volunteer')
        r = api_client.post('/api/v1/users/auth/login/', {'username': 'jwtuser', 'password': 'Pass12345!x'}, format='json')
        assert r.status_code == 200
        return r.data['access'], r.data['refresh']

    def test_logout_blacklists_refresh(self, api_client):
        access, refresh = self._login(api_client)
        api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        assert api_client.post('/api/v1/users/auth/logout/', {'refresh': refresh}, format='json').status_code == 205
        api_client.credentials()
        r = api_client.post('/api/v1/users/auth/token/refresh/', {'refresh': refresh}, format='json')
        assert r.status_code == 401

    def test_refresh_rotates(self, api_client):
        _, refresh = self._login(api_client)
        r = api_client.post('/api/v1/users/auth/token/refresh/', {'refresh': refresh}, format='json')
        assert r.status_code == 200 and 'refresh' in r.data
        # old refresh is blacklisted after rotation
        assert api_client.post('/api/v1/users/auth/token/refresh/', {'refresh': refresh}, format='json').status_code == 401


@pytest.mark.django_db
class TestObjectOwnership:
    def test_other_ngo_cannot_delete_event(self, api_client, ngo_user):
        event = Event.objects.create(title='E', description='d', category='ecology', organizer=ngo_user,
                                     date=timezone.now() + timedelta(days=1), location='B', hours=2, spots_total=5)
        other = User.objects.create_user(username='ngo2', email='n2@t.com', password='p', role='ngo')
        api_client.force_authenticate(other)
        assert api_client.delete(f'/api/v1/events/{event.id}/').status_code == 403
        assert Event.objects.filter(pk=event.pk).exists()

    def test_other_user_cannot_edit_initiative(self, api_client, volunteer_user):
        ini = Initiative.objects.create(title='I', description='d', category='ecology', location='B',
                                        author=volunteer_user, hours_claimed=5)
        other = User.objects.create_user(username='v2', email='v2@t.com', password='p', role='volunteer')
        api_client.force_authenticate(other)
        assert api_client.patch(f'/api/v1/initiatives/{ini.id}/', {'title': 'hacked'}, format='json').status_code == 403


@pytest.mark.django_db
def test_public_stats_are_real(api_client, volunteer_user, ngo_user):
    from django.core.cache import cache
    cache.clear()
    r = api_client.get('/api/v1/users/public-stats/')
    assert r.status_code == 200
    assert r.data['volunteers'] >= 1 and r.data['organizations'] >= 1 and 'events' in r.data
