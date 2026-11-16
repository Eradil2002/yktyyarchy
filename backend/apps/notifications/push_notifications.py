from firebase_admin import messaging
from django.conf import settings
import logging

logger = logging.getLogger(__name__)


def send_push_notification(user, title, body, data=None):
    """
    Send push notification to a user via Firebase Cloud Messaging.

    Args:
        user: User instance
        title: Notification title
        body: Notification body
        data: Optional dict with additional data

    Returns:
        bool: Success status
    """
    # Get user's FCM token from profile
    fcm_token = None

    if hasattr(user, 'volunteer_profile') and user.volunteer_profile:
        fcm_token = getattr(user.volunteer_profile, 'fcm_token', None)
    elif hasattr(user, 'ngo_profile') and user.ngo_profile:
        fcm_token = getattr(user.ngo_profile, 'fcm_token', None)

    if not fcm_token:
        logger.warning(f"No FCM token found for user {user.id}")
        return False

    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=fcm_token,
        )

        response = messaging.send(message)
        logger.info(f"Successfully sent message to user {user.id}: {response}")
        return True

    except Exception as e:
        logger.error(f"Error sending push notification to user {user.id}: {e}")
        return False


def send_bulk_push_notification(users, title, body, data=None):
    """
    Send push notification to multiple users.

    Args:
        users: QuerySet or list of User instances
        title: Notification title
        body: Notification body
        data: Optional dict with additional data

    Returns:
        dict: Success and failure counts
    """
    success_count = 0
    failure_count = 0

    for user in users:
        if send_push_notification(user, title, body, data):
            success_count += 1
        else:
            failure_count += 1

    return {
        'success': success_count,
        'failure': failure_count,
        'total': success_count + failure_count
    }


def notify_new_event(event):
    """
    Notify volunteers about a new event matching their interests.

    Args:
        event: Event instance
    """
    from apps.users.models import CustomUser
    from apps.events.models import EventRegistration

    # Get volunteers who might be interested
    volunteers = CustomUser.objects.filter(role='volunteer')

    # Filter by category interest (volunteers who participated in similar events)
    interested_volunteers = volunteers.filter(
        registrations__event__category=event.category
    ).distinct()

    # Also notify volunteers in the same location
    if event.location:
        location_volunteers = volunteers.filter(
            location__icontains=event.location.split(',')[0]  # City name
        )
        interested_volunteers = interested_volunteers | location_volunteers

    interested_volunteers = interested_volunteers.distinct()

    title = "Новое мероприятие!"
    body = f"{event.title} - {event.date.strftime('%d.%m.%Y')}"
    data = {
        'type': 'new_event',
        'event_id': str(event.id),
        'category': event.category
    }

    result = send_bulk_push_notification(interested_volunteers, title, body, data)
    logger.info(f"Notified {result['success']} volunteers about new event {event.id}")

    return result


def notify_event_reminder(event, hours_before):
    """
    Send reminder notification to registered volunteers.

    Args:
        event: Event instance
        hours_before: Hours before event (24 or 1)
    """
    from apps.events.models import EventRegistration

    # Get approved registrations
    registrations = EventRegistration.objects.filter(
        event=event,
        status='approved'
    ).select_related('volunteer')

    if hours_before == 24:
        title = "Напоминание: мероприятие завтра!"
        body = f"{event.title} начнется завтра в {event.date.strftime('%H:%M')}"
    else:
        title = "Напоминание: мероприятие через час!"
        body = f"{event.title} начнется через час"

    data = {
        'type': 'event_reminder',
        'event_id': str(event.id),
        'hours_before': str(hours_before)
    }

    volunteers = [reg.volunteer for reg in registrations]
    result = send_bulk_push_notification(volunteers, title, body, data)

    logger.info(f"Sent {hours_before}h reminder to {result['success']} volunteers for event {event.id}")

    return result


def notify_event_update(event, message):
    """
    Notify registered volunteers about event updates.

    Args:
        event: Event instance
        message: Update message
    """
    from apps.events.models import EventRegistration

    registrations = EventRegistration.objects.filter(
        event=event,
        status__in=['approved', 'pending']
    ).select_related('volunteer')

    title = f"Обновление: {event.title}"
    body = message
    data = {
        'type': 'event_update',
        'event_id': str(event.id)
    }

    volunteers = [reg.volunteer for reg in registrations]
    result = send_bulk_push_notification(volunteers, title, body, data)

    return result


def notify_registration_status(registration):
    """
    Notify volunteer about registration status change.

    Args:
        registration: EventRegistration instance
    """
    status_messages = {
        'approved': 'Ваша регистрация одобрена!',
        'rejected': 'К сожалению, ваша регистрация отклонена',
        'cancelled': 'Ваша регистрация отменена'
    }

    if registration.status not in status_messages:
        return False

    title = f"Статус регистрации: {registration.event.title}"
    body = status_messages[registration.status]
    data = {
        'type': 'registration_status',
        'event_id': str(registration.event.id),
        'status': registration.status
    }

    return send_push_notification(registration.volunteer, title, body, data)
