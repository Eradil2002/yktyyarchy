import bleach
import html
from django.utils.html import strip_tags


def sanitize_html(text, allow_tags=None):
    """
    Sanitize HTML content to prevent XSS attacks.

    Args:
        text: Input text that may contain HTML
        allow_tags: List of allowed HTML tags (default: None = strip all)

    Returns:
        Sanitized text
    """
    if not text:
        return text

    if allow_tags is None:
        # Strip all HTML tags by default
        return strip_tags(text)

    # Allow specific tags with bleach
    allowed_tags = allow_tags or []
    allowed_attributes = {
        'a': ['href', 'title'],
        'img': ['src', 'alt'],
    }

    return bleach.clean(
        text,
        tags=allowed_tags,
        attributes=allowed_attributes,
        strip=True
    )


def sanitize_text_input(text):
    """
    Sanitize plain text input by escaping HTML entities.
    Use for user inputs like names, descriptions, etc.
    """
    if not text:
        return text

    # Escape HTML entities
    return html.escape(text)


def sanitize_user_profile_data(data):
    """
    Sanitize user profile data fields.
    """
    sanitized = {}

    # Fields that should be completely stripped of HTML
    plain_text_fields = ['first_name', 'last_name', 'username', 'location', 'org_name']

    # Fields that can have limited HTML (like bio, description)
    rich_text_fields = ['bio', 'description']
    allowed_tags = ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li', 'a']

    for key, value in data.items():
        if not isinstance(value, str):
            sanitized[key] = value
            continue

        if key in plain_text_fields:
            sanitized[key] = sanitize_text_input(value)
        elif key in rich_text_fields:
            sanitized[key] = sanitize_html(value, allow_tags=allowed_tags)
        else:
            sanitized[key] = value

    return sanitized


def sanitize_event_data(data):
    """
    Sanitize event data fields.
    """
    sanitized = {}

    plain_text_fields = ['title', 'location', 'category']
    rich_text_fields = ['description', 'requirements']
    allowed_tags = ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li', 'a']

    for key, value in data.items():
        if not isinstance(value, str):
            sanitized[key] = value
            continue

        if key in plain_text_fields:
            sanitized[key] = sanitize_text_input(value)
        elif key in rich_text_fields:
            sanitized[key] = sanitize_html(value, allow_tags=allowed_tags)
        else:
            sanitized[key] = value

    return sanitized


def sanitize_initiative_data(data):
    """
    Sanitize initiative data fields.
    """
    sanitized = {}

    plain_text_fields = ['title', 'location', 'category']
    rich_text_fields = ['description', 'goals']
    allowed_tags = ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li', 'a']

    for key, value in data.items():
        if not isinstance(value, str):
            sanitized[key] = value
            continue

        if key in plain_text_fields:
            sanitized[key] = sanitize_text_input(value)
        elif key in rich_text_fields:
            sanitized[key] = sanitize_html(value, allow_tags=allowed_tags)
        else:
            sanitized[key] = value

    return sanitized


def sanitize_review_data(data):
    """
    Sanitize review/comment data.
    """
    sanitized = {}

    # Reviews should have minimal HTML
    for key, value in data.items():
        if not isinstance(value, str):
            sanitized[key] = value
            continue

        if key in ['comment', 'text', 'content']:
            # Allow only basic formatting
            sanitized[key] = sanitize_html(value, allow_tags=['p', 'br'])
        else:
            sanitized[key] = sanitize_text_input(value)

    return sanitized
