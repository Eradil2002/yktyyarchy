from rest_framework.throttling import AnonRateThrottle, UserRateThrottle
from django.core.cache import cache
from rest_framework.exceptions import Throttled


class IPBasedLoginThrottle(AnonRateThrottle):
    """
    Strict IP-based throttling for login attempts.
    Blocks IP after too many failed login attempts.
    """
    scope = 'login_ip'

    def get_cache_key(self, request, view):
        if request.user.is_authenticated:
            return None  # Only throttle anonymous requests

        ident = self.get_ident(request)
        return self.cache_format % {
            'scope': self.scope,
            'ident': ident
        }


class IPBasedRegisterThrottle(AnonRateThrottle):
    """
    Strict IP-based throttling for registration.
    Prevents mass account creation from single IP.
    """
    scope = 'register_ip'

    def get_cache_key(self, request, view):
        ident = self.get_ident(request)
        return self.cache_format % {
            'scope': self.scope,
            'ident': ident
        }


class IPBasedPasswordResetThrottle(AnonRateThrottle):
    """
    Strict IP-based throttling for password reset requests.
    Prevents abuse of password reset functionality.
    """
    scope = 'password_reset_ip'

    def get_cache_key(self, request, view):
        ident = self.get_ident(request)
        return self.cache_format % {
            'scope': self.scope,
            'ident': ident
        }


class IPBasedOTPThrottle(AnonRateThrottle):
    """
    Very strict throttling for OTP requests.
    Prevents SMS/WhatsApp spam.
    """
    scope = 'otp_ip'

    def get_cache_key(self, request, view):
        ident = self.get_ident(request)
        return self.cache_format % {
            'scope': self.scope,
            'ident': ident
        }


def check_failed_login_attempts(ip_address, username):
    """
    Check if IP or username has too many failed login attempts.
    Returns (is_blocked, remaining_time_seconds)
    """
    ip_key = f'failed_login_ip:{ip_address}'
    user_key = f'failed_login_user:{username}'

    ip_attempts = cache.get(ip_key, 0)
    user_attempts = cache.get(user_key, 0)

    # Block after 5 failed attempts from same IP
    if ip_attempts >= 5:
        ttl = cache.ttl(ip_key)
        return True, ttl if ttl else 3600

    # Block after 3 failed attempts for same username
    if user_attempts >= 3:
        ttl = cache.ttl(user_key)
        return True, ttl if ttl else 3600

    return False, 0


def record_failed_login(ip_address, username):
    """
    Record a failed login attempt.
    Blocks are progressive: 1h, 3h, 24h
    """
    ip_key = f'failed_login_ip:{ip_address}'
    user_key = f'failed_login_user:{username}'

    # Increment counters
    ip_attempts = cache.get(ip_key, 0) + 1
    user_attempts = cache.get(user_key, 0) + 1

    # Progressive blocking
    if ip_attempts <= 5:
        timeout = 3600  # 1 hour
    elif ip_attempts <= 10:
        timeout = 10800  # 3 hours
    else:
        timeout = 86400  # 24 hours

    cache.set(ip_key, ip_attempts, timeout)
    cache.set(user_key, user_attempts, timeout)


def clear_failed_login_attempts(ip_address, username):
    """
    Clear failed login attempts after successful login.
    """
    ip_key = f'failed_login_ip:{ip_address}'
    user_key = f'failed_login_user:{username}'

    cache.delete(ip_key)
    cache.delete(user_key)


class PasswordResetConfirmThrottle(AnonRateThrottle):
    """Limits password-reset confirmation attempts per IP (token brute force)."""
    scope = 'password_reset_confirm'
