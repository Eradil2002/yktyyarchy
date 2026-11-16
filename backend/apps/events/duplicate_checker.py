from django.db.models import Q
from datetime import timedelta
from difflib import SequenceMatcher


def check_duplicate_events(title, date, location, organizer, category=None):
    """
    Check if there are similar events that might be duplicates.

    Returns:
        list: List of potentially duplicate events
    """
    from apps.events.models import Event

    # Search for events within 3 days of the given date
    date_range_start = date - timedelta(days=3)
    date_range_end = date + timedelta(days=3)

    # Find events by same organizer in similar timeframe
    similar_events = Event.objects.filter(
        organizer=organizer,
        date__range=[date_range_start, date_range_end]
    )

    # If category provided, filter by it
    if category:
        similar_events = similar_events.filter(category=category)

    duplicates = []

    for event in similar_events:
        # Calculate title similarity
        title_similarity = SequenceMatcher(None, title.lower(), event.title.lower()).ratio()

        # Calculate location similarity
        location_similarity = SequenceMatcher(None, location.lower(), event.location.lower()).ratio()

        # If title is very similar (>80%) and location is similar (>70%), it's likely a duplicate
        if title_similarity > 0.8 and location_similarity > 0.7:
            duplicates.append({
                'id': event.id,
                'title': event.title,
                'date': event.date,
                'location': event.location,
                'title_similarity': round(title_similarity * 100, 1),
                'location_similarity': round(location_similarity * 100, 1)
            })

    return duplicates


def find_similar_events(title, category=None, limit=5):
    """
    Find events with similar titles (for recommendations or duplicate detection).

    Returns:
        QuerySet: Similar events
    """
    from apps.events.models import Event

    # Split title into words for search
    words = title.lower().split()

    # Build Q objects for each word
    query = Q()
    for word in words:
        if len(word) > 3:  # Only search for words longer than 3 characters
            query |= Q(title__icontains=word) | Q(description__icontains=word)

    queryset = Event.objects.filter(query)

    if category:
        queryset = queryset.filter(category=category)

    return queryset[:limit]
