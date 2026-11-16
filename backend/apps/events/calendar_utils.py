from datetime import datetime, timedelta
from django.utils import timezone
from collections import defaultdict


def get_events_by_month(year, month, user=None):
    """
    Get events grouped by day for a specific month.

    Args:
        year: Year (e.g., 2026)
        month: Month (1-12)
        user: Optional user for filtering registered events

    Returns:
        dict: Events grouped by day
    """
    from apps.events.models import Event, EventRegistration

    # Get first and last day of month
    first_day = datetime(year, month, 1, tzinfo=timezone.get_current_timezone())
    if month == 12:
        last_day = datetime(year + 1, 1, 1, tzinfo=timezone.get_current_timezone())
    else:
        last_day = datetime(year, month + 1, 1, tzinfo=timezone.get_current_timezone())

    # Get events in this month
    events = Event.objects.filter(
        date__gte=first_day,
        date__lt=last_day
    ).order_by('date')

    # Group by day
    events_by_day = defaultdict(list)

    for event in events:
        day = event.date.day

        event_data = {
            'id': event.id,
            'title': event.title,
            'time': event.date.strftime('%H:%M'),
            'category': event.category,
            'status': event.status,
            'is_urgent': event.is_urgent,
            'spots_available': event.spots_total - event.spots_booked,
        }

        # Check if user is registered
        if user:
            is_registered = EventRegistration.objects.filter(
                event=event,
                volunteer=user
            ).exists()
            event_data['is_registered'] = is_registered

        events_by_day[day].append(event_data)

    return dict(events_by_day)


def get_events_by_week(year, week_number, user=None):
    """
    Get events for a specific week.

    Args:
        year: Year
        week_number: ISO week number (1-53)
        user: Optional user for filtering

    Returns:
        dict: Events grouped by day of week
    """
    from apps.events.models import Event, EventRegistration

    # Get first day of week
    first_day = datetime.strptime(f'{year}-W{week_number}-1', '%Y-W%W-%w')
    first_day = timezone.make_aware(first_day)
    last_day = first_day + timedelta(days=7)

    # Get events in this week
    events = Event.objects.filter(
        date__gte=first_day,
        date__lt=last_day
    ).order_by('date')

    # Group by day of week (0=Monday, 6=Sunday)
    events_by_day = defaultdict(list)

    for event in events:
        day_of_week = event.date.weekday()

        event_data = {
            'id': event.id,
            'title': event.title,
            'date': event.date.strftime('%Y-%m-%d'),
            'time': event.date.strftime('%H:%M'),
            'category': event.category,
            'status': event.status,
            'is_urgent': event.is_urgent,
        }

        if user:
            is_registered = EventRegistration.objects.filter(
                event=event,
                volunteer=user
            ).exists()
            event_data['is_registered'] = is_registered

        events_by_day[day_of_week].append(event_data)

    return dict(events_by_day)


def get_calendar_summary(year, month, user=None):
    """
    Get calendar summary with event counts per day.

    Args:
        year: Year
        month: Month
        user: Optional user

    Returns:
        dict: Summary with event counts
    """
    from apps.events.models import Event

    first_day = datetime(year, month, 1, tzinfo=timezone.get_current_timezone())
    if month == 12:
        last_day = datetime(year + 1, 1, 1, tzinfo=timezone.get_current_timezone())
    else:
        last_day = datetime(year, month + 1, 1, tzinfo=timezone.get_current_timezone())

    events = Event.objects.filter(
        date__gte=first_day,
        date__lt=last_day
    )

    # Count events per day
    event_counts = defaultdict(int)
    urgent_days = set()

    for event in events:
        day = event.date.day
        event_counts[day] += 1
        if event.is_urgent:
            urgent_days.add(day)

    return {
        'year': year,
        'month': month,
        'total_events': events.count(),
        'event_counts': dict(event_counts),
        'urgent_days': list(urgent_days)
    }
