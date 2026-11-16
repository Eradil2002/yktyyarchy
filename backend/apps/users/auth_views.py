from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.response import Response
from rest_framework import status
from .throttling import (
    IPBasedLoginThrottle,
    check_failed_login_attempts,
    record_failed_login,
    clear_failed_login_attempts
)
from .security_log import log_security_event


class CustomTokenObtainPairView(TokenObtainPairView):
    """
    Custom login view with failed attempt tracking and IP-based throttling.
    """
    throttle_classes = [IPBasedLoginThrottle]

    def get_client_ip(self, request):
        """Get client IP address from request"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip

    def post(self, request, *args, **kwargs):
        username = request.data.get('username', '')
        ip_address = self.get_client_ip(request)

        # Check if IP or username is blocked due to failed attempts
        is_blocked, remaining_time = check_failed_login_attempts(ip_address, username)

        if is_blocked:
            minutes = remaining_time // 60
            log_security_event(
                'login_failed',
                request=request,
                username=username,
                details={
                    'reason': 'too_many_attempts',
                    'blocked_for_seconds': remaining_time
                }
            )
            return Response(
                {
                    'detail': f'Слишком много неудачных попыток входа. Попробуйте снова через {minutes} минут.'
                },
                status=status.HTTP_429_TOO_MANY_REQUESTS
            )

        # Try to authenticate
        response = super().post(request, *args, **kwargs)

        # If login successful
        if response.status_code == 200:
            # Clear failed attempts
            clear_failed_login_attempts(ip_address, username)

            # Log successful login
            try:
                from .models import CustomUser
                user = CustomUser.objects.get(username=username)
                log_security_event('login_success', request=request, user=user)
            except:
                pass

        # If login failed
        else:
            # Record failed attempt
            record_failed_login(ip_address, username)

            # Log failed login
            log_security_event(
                'login_failed',
                request=request,
                username=username,
                details={'reason': 'invalid_credentials'}
            )

        return response
