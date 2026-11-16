from django.core.exceptions import ValidationError
from django.utils.translation import gettext as _
import re


class CustomPasswordValidator:
    """
    Validate that the password contains at least:
    - 1 uppercase letter
    - 1 lowercase letter
    - 1 digit
    - 1 special character
    - Minimum 8 characters
    """

    def validate(self, password, user=None):
        if len(password) < 8:
            raise ValidationError(
                _("Пароль должен содержать минимум 8 символов."),
                code='password_too_short',
            )

        if not re.search(r'[A-Z]', password):
            raise ValidationError(
                _("Пароль должен содержать хотя бы одну заглавную букву."),
                code='password_no_upper',
            )

        if not re.search(r'[a-z]', password):
            raise ValidationError(
                _("Пароль должен содержать хотя бы одну строчную букву."),
                code='password_no_lower',
            )

        if not re.search(r'\d', password):
            raise ValidationError(
                _("Пароль должен содержать хотя бы одну цифру."),
                code='password_no_digit',
            )

        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            raise ValidationError(
                _("Пароль должен содержать хотя бы один специальный символ (!@#$%^&*(),.?\":{}|<>)."),
                code='password_no_special',
            )

    def get_help_text(self):
        return _(
            "Ваш пароль должен содержать минимум 8 символов, включая заглавные и строчные буквы, цифры и специальные символы."
        )
