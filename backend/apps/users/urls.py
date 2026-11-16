from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .auth_views import CustomTokenObtainPairView
from .views import (
    RegisterView, UserProfileView, VolunteerListView, UserDetailView,
    EmailVerificationView, ResendVerificationCodeView,
    PasswordResetRequestView, PasswordResetConfirmView,
    WhatsAppOTPRequestView, WhatsAppOTPVerifyView, ExportVolunteerBookView,
    RegisterFCMTokenView, LogoutView, PublicStatsView
)

urlpatterns = [
    # Authentication
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', CustomTokenObtainPairView.as_view(), name='login'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/logout/', LogoutView.as_view(), name='logout'),

    # Email verification
    path('auth/verify-email/', EmailVerificationView.as_view(), name='verify_email'),
    path('auth/resend-verification/', ResendVerificationCodeView.as_view(), name='resend_verification'),
    path('auth/whatsapp/request-otp/', WhatsAppOTPRequestView.as_view(), name='whatsapp_request_otp'),
    path('auth/whatsapp/verify-otp/', WhatsAppOTPVerifyView.as_view(), name='whatsapp_verify_otp'),

    # Password reset
    path('auth/password-reset/', PasswordResetRequestView.as_view(), name='password_reset_request'),
    path('auth/password-reset-confirm/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),

    # User profile
    path('me/', UserProfileView.as_view(), name='my_profile'),
    path('me/export-pdf/', ExportVolunteerBookView.as_view(), name='export_volunteer_book'),
    path('me/register-fcm/', RegisterFCMTokenView.as_view(), name='register_fcm_token'),
    path('public-stats/', PublicStatsView.as_view(), name='public_stats'),
    path('volunteers/', VolunteerListView.as_view(), name='volunteer_list'),
    path('<int:pk>/', UserDetailView.as_view(), name='user_detail'),
]
