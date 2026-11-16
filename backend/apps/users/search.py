"""
Full-text search utilities for events, initiatives, and users.
Uses PostgreSQL full-text search capabilities.
"""
from django.contrib.postgres.search import SearchVector, SearchQuery, SearchRank
from django.db.models import Q
from apps.events.models import Event
from apps.initiatives.models import Initiative
from apps.users.models import CustomUser


def search_events(query_string, filters=None):
    """
    Full-text search for events.

    Args:
        query_string: Search query string
        filters: Optional dictionary of additional filters

    Returns:
        QuerySet of matching events ordered by relevance
    """
    if not query_string:
        queryset = Event.objects.all()
    else:
        # Create search vector for multiple fields
        search_vector = SearchVector('title', weight='A') + \
                       SearchVector('description', weight='B') + \
                       SearchVector('location', weight='C') + \
                       SearchVector('category', weight='C')

        search_query = SearchQuery(query_string, search_type='websearch')

        queryset = Event.objects.annotate(
            search=search_vector,
            rank=SearchRank(search_vector, search_query)
        ).filter(search=search_query).order_by('-rank')

    # Apply additional filters
    if filters:
        if 'category' in filters:
            queryset = queryset.filter(category=filters['category'])
        if 'status' in filters:
            queryset = queryset.filter(status=filters['status'])
        if 'type' in filters:
            queryset = queryset.filter(type=filters['type'])
        if 'is_urgent' in filters:
            queryset = queryset.filter(is_urgent=filters['is_urgent'])

    return queryset


def search_initiatives(query_string, filters=None):
    """
    Full-text search for initiatives.

    Args:
        query_string: Search query string
        filters: Optional dictionary of additional filters

    Returns:
        QuerySet of matching initiatives ordered by relevance
    """
    if not query_string:
        queryset = Initiative.objects.all()
    else:
        # Create search vector for multiple fields
        search_vector = SearchVector('title', weight='A') + \
                       SearchVector('description', weight='B') + \
                       SearchVector('location', weight='C') + \
                       SearchVector('category', weight='C')

        search_query = SearchQuery(query_string, search_type='websearch')

        queryset = Initiative.objects.annotate(
            search=search_vector,
            rank=SearchRank(search_vector, search_query)
        ).filter(search=search_query).order_by('-rank')

    # Apply additional filters
    if filters:
        if 'category' in filters:
            queryset = queryset.filter(category=filters['category'])
        if 'status' in filters:
            queryset = queryset.filter(status=filters['status'])

    return queryset


def search_users(query_string, filters=None):
    """
    Full-text search for users.

    Args:
        query_string: Search query string
        filters: Optional dictionary of additional filters

    Returns:
        QuerySet of matching users ordered by relevance
    """
    if not query_string:
        queryset = CustomUser.objects.all()
    else:
        # Create search vector for multiple fields
        search_vector = SearchVector('username', weight='A') + \
                       SearchVector('first_name', weight='B') + \
                       SearchVector('last_name', weight='B') + \
                       SearchVector('email', weight='C') + \
                       SearchVector('location', weight='D')

        search_query = SearchQuery(query_string, search_type='websearch')

        queryset = CustomUser.objects.annotate(
            search=search_vector,
            rank=SearchRank(search_vector, search_query)
        ).filter(search=search_query).order_by('-rank')

    # Apply additional filters
    if filters:
        if 'role' in filters:
            queryset = queryset.filter(role=filters['role'])
        if 'is_verified' in filters:
            queryset = queryset.filter(is_verified=filters['is_verified'])

    return queryset


def global_search(query_string, limit=10):
    """
    Search across all models (events, initiatives, users).

    Args:
        query_string: Search query string
        limit: Maximum results per model type

    Returns:
        Dictionary with results from each model type
    """
    results = {
        'events': list(search_events(query_string)[:limit]),
        'initiatives': list(search_initiatives(query_string)[:limit]),
        'users': list(search_users(query_string)[:limit]),
    }

    return results


def search_events_simple(query_string):
    """
    Simple search for events without PostgreSQL full-text search.
    Fallback for SQLite or when full-text search is not available.

    Args:
        query_string: Search query string

    Returns:
        QuerySet of matching events
    """
    if not query_string:
        return Event.objects.all()

    return Event.objects.filter(
        Q(title__icontains=query_string) |
        Q(description__icontains=query_string) |
        Q(location__icontains=query_string) |
        Q(category__icontains=query_string)
    )


def search_initiatives_simple(query_string):
    """
    Simple search for initiatives without PostgreSQL full-text search.
    Fallback for SQLite or when full-text search is not available.

    Args:
        query_string: Search query string

    Returns:
        QuerySet of matching initiatives
    """
    if not query_string:
        return Initiative.objects.all()

    return Initiative.objects.filter(
        Q(title__icontains=query_string) |
        Q(description__icontains=query_string) |
        Q(location__icontains=query_string) |
        Q(category__icontains=query_string)
    )


def search_users_simple(query_string):
    """
    Simple search for users without PostgreSQL full-text search.
    Fallback for SQLite or when full-text search is not available.

    Args:
        query_string: Search query string

    Returns:
        QuerySet of matching users
    """
    if not query_string:
        return CustomUser.objects.all()

    return CustomUser.objects.filter(
        Q(username__icontains=query_string) |
        Q(first_name__icontains=query_string) |
        Q(last_name__icontains=query_string) |
        Q(email__icontains=query_string) |
        Q(location__icontains=query_string)
    )
