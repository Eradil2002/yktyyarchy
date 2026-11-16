from django.db.models import Count, Sum, Avg, Q
from django.utils import timezone
from datetime import timedelta


def get_ngo_statistics(ngo_user):
    """
    Get comprehensive statistics for NGO dashboard.

    Args:
        ngo_user: User instance with role='ngo'

    Returns:
        dict: Statistics data
    """
    from apps.events.models import Event, EventRegistration
    from apps.reviews.models import Review

    # Get all events organized by this NGO
    events = Event.objects.filter(organizer=ngo_user)

    # Total events
    total_events = events.count()
    open_events = events.filter(status='open').count()
    completed_events = events.filter(status='completed').count()

    # Volunteer statistics
    total_registrations = EventRegistration.objects.filter(event__organizer=ngo_user).count()
    approved_registrations = EventRegistration.objects.filter(
        event__organizer=ngo_user,
        status='approved'
    ).count()
    attended_registrations = EventRegistration.objects.filter(
        event__organizer=ngo_user,
        status='attended'
    ).count()

    # Unique volunteers
    unique_volunteers = EventRegistration.objects.filter(
        event__organizer=ngo_user
    ).values('volunteer').distinct().count()

    # Total volunteer hours
    total_hours = events.aggregate(total=Sum('hours'))['total'] or 0

    # Average rating from reviews
    avg_rating = Review.objects.filter(
        target_user=ngo_user,
        moderation_status='approved'
    ).aggregate(avg=Avg('rating'))['avg'] or 0.0

    # Recent activity (last 30 days)
    thirty_days_ago = timezone.now() - timedelta(days=30)
    recent_events = events.filter(created_at__gte=thirty_days_ago).count()
    recent_registrations = EventRegistration.objects.filter(
        event__organizer=ngo_user,
        registered_at__gte=thirty_days_ago
    ).count()

    # Events by category
    events_by_category = events.values('category').annotate(
        count=Count('id')
    ).order_by('-count')

    # Events by status
    events_by_status = {
        'open': open_events,
        'closed': events.filter(status='closed').count(),
        'completed': completed_events
    }

    # Upcoming events
    upcoming_events = events.filter(
        date__gte=timezone.now(),
        status='open'
    ).count()

    return {
        'total_events': total_events,
        'open_events': open_events,
        'completed_events': completed_events,
        'upcoming_events': upcoming_events,
        'total_registrations': total_registrations,
        'approved_registrations': approved_registrations,
        'attended_registrations': attended_registrations,
        'unique_volunteers': unique_volunteers,
        'total_volunteer_hours': total_hours,
        'average_rating': round(avg_rating, 1),
        'recent_activity': {
            'events_created': recent_events,
            'new_registrations': recent_registrations
        },
        'events_by_category': list(events_by_category),
        'events_by_status': events_by_status
    }


def get_event_statistics(event):
    """
    Get statistics for a specific event.

    Args:
        event: Event instance

    Returns:
        dict: Event statistics
    """
    from apps.events.models import EventRegistration

    registrations = EventRegistration.objects.filter(event=event)

    total_registrations = registrations.count()
    approved = registrations.filter(status='approved').count()
    pending = registrations.filter(status='pending').count()
    attended = registrations.filter(status='attended').count()
    cancelled = registrations.filter(status='cancelled').count()

    spots_available = event.spots_total - event.spots_booked

    return {
        'event_id': event.id,
        'event_title': event.title,
        'total_registrations': total_registrations,
        'approved': approved,
        'pending': pending,
        'attended': attended,
        'cancelled': cancelled,
        'spots_total': event.spots_total,
        'spots_booked': event.spots_booked,
        'spots_available': spots_available,
        'fill_rate': round((event.spots_booked / event.spots_total * 100), 1) if event.spots_total > 0 else 0
    }
