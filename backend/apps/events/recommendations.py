from django.db.models import Q, Count
from datetime import timedelta
from django.utils import timezone


def get_recommended_events(user, limit=10):
    """
    Get recommended events for a volunteer based on their interests and history.

    Args:
        user: User instance (volunteer)
        limit: Maximum number of recommendations

    Returns:
        QuerySet: Recommended events
    """
    from apps.events.models import Event, EventRegistration

    # Get user's past event categories
    past_registrations = EventRegistration.objects.filter(
        volunteer=user
    ).select_related('event')

    # Get categories user has participated in
    user_categories = past_registrations.values_list('event__category', flat=True).distinct()

    # Get user's skills from profile
    user_skills = []
    if hasattr(user, 'volunteer_profile') and user.volunteer_profile:
        user_skills = user.volunteer_profile.skills or []

    # Build recommendation query
    recommendations = Event.objects.filter(
        status='open',
        date__gte=timezone.now()
    ).exclude(
        # Exclude events user is already registered for
        registrations__volunteer=user
    )

    # Score events based on relevance
    scored_events = []

    for event in recommendations:
        score = 0

        # Category match (highest weight)
        if event.category in user_categories:
            score += 50

        # Skills match
        event_requirements = event.requirements or []
        matching_skills = set(user_skills) & set(event_requirements)
        score += len(matching_skills) * 10

        # Location proximity (if user has location)
        if user.location and event.location:
            if user.location.lower() in event.location.lower():
                score += 20

        # Urgency bonus
        if event.is_urgent:
            score += 15

        # Recent events bonus (created in last 7 days)
        if event.created_at >= timezone.now() - timedelta(days=7):
            score += 10

        # Events happening soon (within 7 days)
        if event.date <= timezone.now() + timedelta(days=7):
            score += 5

        scored_events.append((event, score))

    # Sort by score and return top recommendations
    scored_events.sort(key=lambda x: x[1], reverse=True)
    recommended = [event for event, score in scored_events[:limit]]

    return recommended


def get_similar_events(event, limit=5):
    """
    Get events similar to the given event.

    Args:
        event: Event instance
        limit: Maximum number of similar events

    Returns:
        QuerySet: Similar events
    """
    from apps.events.models import Event

    similar = Event.objects.filter(
        category=event.category,
        status='open',
        date__gte=timezone.now()
    ).exclude(
        id=event.id
    )

    # Prioritize events by same organizer
    similar = similar.order_by(
        '-organizer__id',  # Same organizer first
        '-date'
    )

    return similar[:limit]


def get_popular_events(limit=10):
    """
    Get most popular events based on registration count.

    Args:
        limit: Maximum number of events

    Returns:
        QuerySet: Popular events
    """
    from apps.events.models import Event

    popular = Event.objects.filter(
        status='open',
        date__gte=timezone.now()
    ).annotate(
        registration_count=Count('registrations')
    ).order_by('-registration_count', '-date')

    return popular[:limit]


def get_events_by_interests(categories, limit=10):
    """
    Get events matching specific categories/interests.

    Args:
        categories: List of category names
        limit: Maximum number of events

    Returns:
        QuerySet: Matching events
    """
    from apps.events.models import Event

    events = Event.objects.filter(
        category__in=categories,
        status='open',
        date__gte=timezone.now()
    ).order_by('-date')

    return events[:limit]
