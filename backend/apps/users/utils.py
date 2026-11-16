from django.core.mail import send_mail
from django.conf import settings
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
import secrets
import requests
import logging

logger = logging.getLogger(__name__)


def send_password_reset_email(user, reset_url_base):
    """
    Send password reset email to user
    reset_url_base should be the frontend URL like: https://app.volunteers.kg/reset-password
    """
    token = default_token_generator.make_token(user)
    uid = urlsafe_base64_encode(force_bytes(user.pk))

    reset_link = f"{reset_url_base}?uid={uid}&token={token}"

    subject = 'Восстановление пароля - Ыктыярчы.kg'
    message = f"""
Здравствуйте, {user.first_name or user.username}!

Вы запросили восстановление пароля для вашего аккаунта на платформе Ыктыярчы.kg.

Для сброса пароля перейдите по ссылке:
{reset_link}

Ссылка действительна в течение 24 часов.

Если вы не запрашивали восстановление пароля, просто проигнорируйте это письмо.

С уважением,
Команда Ыктыярчы.kg
    """

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [user.email],
        fail_silently=False,
    )


def send_email_verification(user, verification_code):
    """
    Send email verification code to user
    """
    subject = 'Подтверждение email - Ыктыярчы.kg'
    message = f"""
Здравствуйте, {user.first_name or user.username}!

Спасибо за регистрацию на платформе Ыктыярчы.kg!

Ваш код подтверждения: {verification_code}

Введите этот код в приложении для завершения регистрации.

Код действителен в течение 24 часов.

С уважением,
Команда Ыктыярчы.kg
    """

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [user.email],
        fail_silently=False,
    )


def generate_verification_code():
    """Generate 6-digit verification code"""
    return ''.join([str(secrets.randbelow(10)) for _ in range(6)])


def send_whatsapp_otp(phone_number, code):
    """
    Send OTP code via WhatsApp using Green API

    Args:
        phone_number: Phone number in format 996555123456 (without +)
        code: 6-digit verification code

    Returns:
        dict: {'success': bool, 'message': str}
    """
    instance_id = getattr(settings, 'GREEN_API_INSTANCE_ID', None)
    api_token = getattr(settings, 'GREEN_API_TOKEN', None)
    api_url = getattr(settings, 'GREEN_API_URL', 'https://api.green-api.com')

    # Check if Green API is configured
    if not instance_id or not api_token:
        logger.warning("Green API not configured. Skipping WhatsApp OTP.")
        return {
            'success': False,
            'message': 'WhatsApp OTP не настроен. Используйте email верификацию.'
        }

    # Format phone number for WhatsApp (add @c.us)
    chat_id = f"{phone_number}@c.us"

    # Prepare message
    message = f"""🔐 Ыктыярчы.kg

Ваш код подтверждения: *{code}*

Код действителен 10 минут.

Если вы не запрашивали код, проигнорируйте это сообщение."""

    # Send request to Green API
    url = f"{api_url}/waInstance{instance_id}/sendMessage/{api_token}"

    payload = {
        "chatId": chat_id,
        "message": message
    }

    try:
        response = requests.post(url, json=payload, timeout=10)
        response.raise_for_status()

        result = response.json()

        if result.get('idMessage'):
            logger.info(f"WhatsApp OTP sent successfully to {phone_number}")
            return {
                'success': True,
                'message': 'Код отправлен в WhatsApp',
                'message_id': result.get('idMessage')
            }
        else:
            logger.error(f"Green API error: {result}")
            return {
                'success': False,
                'message': 'Ошибка отправки WhatsApp сообщения'
            }

    except requests.exceptions.Timeout:
        logger.error("Green API timeout")
        return {
            'success': False,
            'message': 'Таймаут при отправке WhatsApp сообщения'
        }
    except requests.exceptions.RequestException as e:
        logger.error(f"Green API request error: {e}")
        return {
            'success': False,
            'message': 'Ошибка при отправке WhatsApp сообщения'
        }
    except Exception as e:
        logger.error(f"Unexpected error sending WhatsApp OTP: {e}")
        return {
            'success': False,
            'message': 'Неизвестная ошибка при отправке'
        }


def format_phone_number(phone):
    """
    Format phone number to international format without +

    Examples:
        0555123456 -> 996555123456
        +996555123456 -> 996555123456
        996555123456 -> 996555123456
    """
    # Remove all non-digit characters
    phone = ''.join(filter(str.isdigit, phone))

    # If starts with 0, replace with 996 (Kyrgyzstan)
    if phone.startswith('0'):
        phone = '996' + phone[1:]

    # If doesn't start with country code, add 996
    if not phone.startswith('996'):
        phone = '996' + phone

    return phone
