from django.db.models import Q
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_decode
from django.utils.encoding import force_str
from django.utils import timezone
from datetime import timedelta
import time
import random
import logging
from django.conf import settings
from rest_framework_simplejwt.exceptions import TokenError

logger = logging.getLogger(__name__)
from .models import CustomUser
from .serializers import (
    RegisterSerializer, UserSerializer, EmailVerificationSerializer,
    PasswordResetRequestSerializer, PasswordResetConfirmSerializer,
    WhatsAppOTPRequestSerializer, WhatsAppOTPVerifySerializer
)
from .utils import (
    send_password_reset_email,
    send_email_verification,
    generate_verification_code,
    send_whatsapp_otp,
    format_phone_number,
)
from .security_log import log_security_event
from .throttling import (
    IPBasedLoginThrottle, IPBasedRegisterThrottle,
    IPBasedPasswordResetThrottle, IPBasedOTPThrottle, PasswordResetConfirmThrottle,
    check_failed_login_attempts, record_failed_login,
    clear_failed_login_attempts
)


def add_timing_delay():
    """
    Add random delay to prevent timing attacks.
    Makes it harder to determine if user exists based on response time.
    """
    delay = random.uniform(0.1, 0.3)  # 100-300ms random delay
    time.sleep(delay)


class RegisterView(generics.CreateAPIView):
    queryset = CustomUser.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer
    throttle_classes = [IPBasedRegisterThrottle]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Log registration
        log_security_event('registration', request=request, user=user)

        # Generate and send email verification code
        verification_code = generate_verification_code()
        user.email_verification_code = verification_code
        user.email_verification_code_created = timezone.now()
        user.save()

        try:
            send_email_verification(user, verification_code)
        except Exception as e:
            logger.warning("Failed to send verification email: %s", e)

        refresh = RefreshToken.for_user(user)
        return Response({
            'user': UserSerializer(user).data,
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'message': 'Регистрация успешна. Проверьте email для подтверждения.'
        }, status=status.HTTP_201_CREATED)


class EmailVerificationView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        serializer = EmailVerificationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = request.user
        code = serializer.validated_data['code']

        if user.email_verified:
            return Response({'detail': 'Email уже подтвержден.'}, status=status.HTTP_400_BAD_REQUEST)

        if not user.email_verification_code:
            return Response({'detail': 'Код подтверждения не найден.'}, status=status.HTTP_400_BAD_REQUEST)

        if not user.is_email_verification_code_valid():
            return Response({'detail': 'Код подтверждения истек.'}, status=status.HTTP_400_BAD_REQUEST)

        if user.email_verification_code != code:
            # Log failed verification
            log_security_event('email_verification', request=request, user=user, details={'status': 'failed', 'reason': 'invalid_code'})
            return Response({'detail': 'Неверный код подтверждения.'}, status=status.HTTP_400_BAD_REQUEST)

        user.email_verified = True
        user.email_verification_code = None
        user.email_verification_code_created = None
        user.save()

        # Log successful verification
        log_security_event('email_verification', request=request, user=user, details={'status': 'success'})

        return Response({
            'detail': 'Email успешно подтвержден.',
            'user': UserSerializer(user).data
        }, status=status.HTTP_200_OK)


class ResendVerificationCodeView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        user = request.user

        if user.email_verified:
            return Response({'detail': 'Email уже подтвержден.'}, status=status.HTTP_400_BAD_REQUEST)

        verification_code = generate_verification_code()
        user.email_verification_code = verification_code
        user.email_verification_code_created = timezone.now()
        user.save()

        try:
            send_email_verification(user, verification_code)
            return Response({'detail': 'Код подтверждения отправлен на email.'}, status=status.HTTP_200_OK)
        except Exception:
            logger.exception('Email verification send failed')
            return Response({'detail': 'Не удалось отправить письмо. Попробуйте позже.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class PasswordResetRequestView(APIView):
    permission_classes = (permissions.AllowAny,)
    throttle_classes = [IPBasedPasswordResetThrottle]

    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email']

        # Add timing delay to prevent timing attacks
        add_timing_delay()

        try:
            user = CustomUser.objects.get(email=email)
            # Link base comes ONLY from server config (client-supplied reset_url is ignored: prevents reset-link poisoning)
            reset_url_base = f"{settings.FRONTEND_URL}/#/reset-password"
            send_password_reset_email(user, reset_url_base)

            # Log password reset request
            log_security_event('password_reset_request', request=request, user=user)

        except CustomUser.DoesNotExist:
            # Log failed attempt with email
            log_security_event('password_reset_request', request=request, username=email, details={'status': 'user_not_found'})

        # Always return the same response regardless of whether user exists
        # Don't reveal if user exists or not for security
        return Response({'detail': 'Инструкции по восстановлению пароля отправлены на email.'}, status=status.HTTP_200_OK)


class PasswordResetConfirmView(APIView):
    permission_classes = (permissions.AllowAny,)
    throttle_classes = [PasswordResetConfirmThrottle]

    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            uid = force_str(urlsafe_base64_decode(serializer.validated_data['uid']))
            user = CustomUser.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, CustomUser.DoesNotExist):
            return Response({'detail': 'Неверная ссылка для сброса пароля.'}, status=status.HTTP_400_BAD_REQUEST)

        token = serializer.validated_data['token']
        if not default_token_generator.check_token(user, token):
            # Log failed password reset
            log_security_event('password_reset_complete', request=request, user=user, details={'status': 'failed', 'reason': 'invalid_token'})
            return Response({'detail': 'Токен недействителен или истек.'}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(serializer.validated_data['new_password'])
        user.save()

        # Revoke all existing refresh tokens of this user after password change
        try:
            from rest_framework_simplejwt.token_blacklist.models import OutstandingToken, BlacklistedToken
            for t in OutstandingToken.objects.filter(user=user):
                BlacklistedToken.objects.get_or_create(token=t)
        except Exception:
            logger.exception('Failed to revoke tokens after password reset')

        # Log successful password reset
        log_security_event('password_reset_complete', request=request, user=user, details={'status': 'success'})

        return Response({'detail': 'Пароль успешно изменен.'}, status=status.HTTP_200_OK)


class WhatsAppOTPRequestView(APIView):
    permission_classes = (permissions.AllowAny,)
    throttle_classes = [IPBasedOTPThrottle]

    def post(self, request):
        serializer = WhatsAppOTPRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        raw_phone = serializer.validated_data['phone']
        phone = format_phone_number(raw_phone)

        user, created = CustomUser.objects.get_or_create(
            phone=phone,
            defaults={
                'username': f'wa_{phone}',
                'first_name': 'WhatsApp',
                'last_name': 'User',
                'role': 'volunteer',
            },
        )

        code = generate_verification_code()
        user.email_verification_code = code
        user.email_verification_code_created = timezone.now()
        user.save()

        wa_result = send_whatsapp_otp(phone, code)

        # Log OTP request
        log_security_event('whatsapp_otp_request', request=request, user=user, details={'success': wa_result.get('success'), 'is_new_user': created})

        if not wa_result.get('success'):
            return Response(
                {'detail': wa_result.get('message', 'WhatsApp OTP send failed.')},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        return Response(
            {'detail': 'Код отправлен в WhatsApp.', 'phone': phone, 'is_new_user': created},
            status=status.HTTP_200_OK,
        )


class WhatsAppOTPVerifyView(APIView):
    permission_classes = (permissions.AllowAny,)
    throttle_classes = [IPBasedOTPThrottle]

    def post(self, request):
        serializer = WhatsAppOTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        phone = format_phone_number(serializer.validated_data['phone'])
        code = serializer.validated_data['code']

        try:
            user = CustomUser.objects.get(phone=phone)
        except CustomUser.DoesNotExist:
            return Response({'detail': 'Пользователь не найден.'}, status=status.HTTP_404_NOT_FOUND)

        if not user.email_verification_code or not user.email_verification_code_created:
            return Response({'detail': 'Код не запрошен.'}, status=status.HTTP_400_BAD_REQUEST)

        if timezone.now() - user.email_verification_code_created > timedelta(minutes=10):
            # Log expired code
            log_security_event('whatsapp_otp_verify', request=request, user=user, details={'status': 'failed', 'reason': 'expired'})
            return Response({'detail': 'Код истек.'}, status=status.HTTP_400_BAD_REQUEST)

        if user.email_verification_code != code:
            # Log invalid code
            log_security_event('whatsapp_otp_verify', request=request, user=user, details={'status': 'failed', 'reason': 'invalid_code'})
            return Response({'detail': 'Неверный код.'}, status=status.HTTP_400_BAD_REQUEST)

        user.email_verification_code = None
        user.email_verification_code_created = None
        user.save()

        # Log successful verification
        log_security_event('whatsapp_otp_verify', request=request, user=user, details={'status': 'success'})

        refresh = RefreshToken.for_user(user)
        return Response(
            {
                'user': UserSerializer(user).data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'detail': 'Авторизация через WhatsApp успешна.',
            },
            status=status.HTTP_200_OK,
        )


class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_object(self):
        return self.request.user


class VolunteerListView(generics.ListAPIView):
    """Радар талантов"""
    serializer_class = UserSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        qs = CustomUser.objects.filter(role='volunteer').select_related('volunteer_profile')
        
        # Filtering
        min_rating = self.request.query_params.get('min_rating')
        if min_rating:
            try:
                qs = qs.filter(rating__gte=float(min_rating))
            except ValueError:
                pass
                
        city = self.request.query_params.get('city')
        if city:
            qs = qs.filter(location__icontains=city)
            
        skill = self.request.query_params.get('skill')
        if skill:
            qs = qs.filter(volunteer_profile__skills__contains=skill)
            
        search = self.request.query_params.get('search')
        if search:
            qs = qs.filter(
                Q(first_name__icontains=search) |
                Q(last_name__icontains=search) |
                Q(username__icontains=search)
            )

        return qs.order_by('-rating', '-total_hours')


class UserDetailView(generics.RetrieveAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)


class ExportVolunteerBookView(APIView):
    """
    Export volunteer book as PDF.
    """
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        user = request.user

        # Only volunteers can export their book
        if user.role != 'volunteer':
            return Response(
                {'detail': 'Экспорт доступен только для волонтеров'},
                status=status.HTTP_403_FORBIDDEN
            )

        from .pdf_generator import generate_volunteer_book_pdf
        from django.http import HttpResponse

        # Generate PDF
        pdf_buffer = generate_volunteer_book_pdf(user)

        # Create response
        response = HttpResponse(pdf_buffer, content_type='application/pdf')
        filename = f"volunteer_book_{user.username}_{timezone.now().strftime('%Y%m%d')}.pdf"
        response['Content-Disposition'] = f'attachment; filename="{filename}"'

        return response


class RegisterFCMTokenView(APIView):
    """
    Register FCM token for push notifications.
    """
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        fcm_token = request.data.get('fcm_token')

        if not fcm_token:
            return Response(
                {'detail': 'fcm_token обязателен'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = request.user

        # Save token to user's profile
        if user.role == 'volunteer':
            if hasattr(user, 'volunteer_profile'):
                user.volunteer_profile.fcm_token = fcm_token
                user.volunteer_profile.save()
            else:
                from .models import VolunteerProfile
                VolunteerProfile.objects.create(user=user, fcm_token=fcm_token)

        elif user.role == 'ngo':
            if hasattr(user, 'ngo_profile'):
                user.ngo_profile.fcm_token = fcm_token
                user.ngo_profile.save()
            else:
                from .models import NGOProfile
                NGOProfile.objects.create(user=user, org_name='', fcm_token=fcm_token)

        return Response({'detail': 'FCM токен успешно зарегистрирован'})


class LogoutView(APIView):
    """Blacklist the given refresh token so it can no longer be used."""
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        refresh = request.data.get('refresh')
        if not refresh:
            return Response({'detail': 'refresh token is required.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            token = RefreshToken(refresh)
            if str(token.get('user_id')) != str(request.user.pk):
                return Response({'detail': 'Invalid token.'}, status=status.HTTP_400_BAD_REQUEST)
            token.blacklist()
        except TokenError:
            return Response({'detail': 'Invalid or expired token.'}, status=status.HTTP_400_BAD_REQUEST)
        log_security_event('logout', request=request, user=request.user)
        return Response(status=status.HTTP_205_RESET_CONTENT)


class PublicStatsView(APIView):
    """Real platform counters for the welcome screen (cached 10 min)."""
    permission_classes = (permissions.AllowAny,)

    def get(self, request):
        from django.core.cache import cache
        from apps.events.models import Event
        data = cache.get('public_stats')
        if data is None:
            data = {
                'volunteers': CustomUser.objects.filter(role='volunteer', is_active=True).count(),
                'organizations': CustomUser.objects.filter(role='ngo', is_active=True).count(),
                'events': Event.objects.count(),
            }
            cache.set('public_stats', data, 600)
        return Response(data)
