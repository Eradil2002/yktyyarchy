"""
Redis caching utilities for the volunteer platform.
"""
from django.core.cache import cache
from django.conf import settings
from functools import wraps
import hashlib
import json


def generate_cache_key(prefix, *args, **kwargs):
    """
    Generate a unique cache key based on prefix and arguments.

    Args:
        prefix: Cache key prefix
        *args: Positional arguments to include in key
        **kwargs: Keyword arguments to include in key

    Returns:
        Unique cache key string
    """
    key_data = f"{prefix}:{args}:{sorted(kwargs.items())}"
    key_hash = hashlib.md5(key_data.encode()).hexdigest()
    return f"{prefix}:{key_hash}"


def cache_result(timeout=300, key_prefix='default'):
    """
    Decorator to cache function results in Redis.

    Args:
        timeout: Cache timeout in seconds (default: 300 = 5 minutes)
        key_prefix: Prefix for cache key

    Usage:
        @cache_result(timeout=600, key_prefix='user_stats')
        def get_user_statistics(user_id):
            # expensive operation
            return stats
    """
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            cache_key = generate_cache_key(f"{key_prefix}:{func.__name__}", *args, **kwargs)

            # Try to get from cache
            result = cache.get(cache_key)
            if result is not None:
                return result

            # Execute function and cache result
            result = func(*args, **kwargs)
            cache.set(cache_key, result, timeout)
            return result

        return wrapper
    return decorator


def invalidate_cache(key_prefix, *args, **kwargs):
    """
    Invalidate cached data by key prefix and arguments.

    Args:
        key_prefix: Cache key prefix to invalidate
        *args: Positional arguments used in original cache key
        **kwargs: Keyword arguments used in original cache key
    """
    cache_key = generate_cache_key(key_prefix, *args, **kwargs)
    cache.delete(cache_key)


def invalidate_pattern(pattern):
    """
    Invalidate all cache keys matching a pattern.

    Args:
        pattern: Pattern to match (e.g., 'user:*', 'event:123:*')

    Note: This requires Redis and django-redis backend
    """
    try:
        cache.delete_pattern(pattern)
    except AttributeError:
        # Fallback if delete_pattern is not available
        pass


# Specific cache functions for common operations

def cache_user_stats(user_id, stats, timeout=3600):
    """Cache user statistics for 1 hour."""
    cache_key = f"user_stats:{user_id}"
    cache.set(cache_key, stats, timeout)


def get_cached_user_stats(user_id):
    """Get cached user statistics."""
    cache_key = f"user_stats:{user_id}"
    return cache.get(cache_key)


def invalidate_user_stats(user_id):
    """Invalidate user statistics cache."""
    cache_key = f"user_stats:{user_id}"
    cache.delete(cache_key)


def cache_event_list(filters, events, timeout=300):
    """
    Cache event list with filters for 5 minutes.

    Args:
        filters: Dictionary of filter parameters
        events: List of events to cache
        timeout: Cache timeout in seconds
    """
    cache_key = generate_cache_key('event_list', **filters)
    cache.set(cache_key, events, timeout)


def get_cached_event_list(filters):
    """Get cached event list."""
    cache_key = generate_cache_key('event_list', **filters)
    return cache.get(cache_key)


def invalidate_event_cache():
    """Invalidate all event-related caches."""
    invalidate_pattern('event_list:*')
    invalidate_pattern('event_detail:*')


def cache_event_detail(event_id, event_data, timeout=600):
    """Cache event detail for 10 minutes."""
    cache_key = f"event_detail:{event_id}"
    cache.set(cache_key, event_data, timeout)


def get_cached_event_detail(event_id):
    """Get cached event detail."""
    cache_key = f"event_detail:{event_id}"
    return cache.get(cache_key)


def cache_leaderboard(leaderboard_data, timeout=1800):
    """Cache leaderboard for 30 minutes."""
    cache_key = "leaderboard:global"
    cache.set(cache_key, leaderboard_data, timeout)


def get_cached_leaderboard():
    """Get cached leaderboard."""
    cache_key = "leaderboard:global"
    return cache.get(cache_key)


def invalidate_leaderboard():
    """Invalidate leaderboard cache."""
    cache_key = "leaderboard:global"
    cache.delete(cache_key)


def cache_ngo_stats(ngo_id, stats, timeout=3600):
    """Cache NGO statistics for 1 hour."""
    cache_key = f"ngo_stats:{ngo_id}"
    cache.set(cache_key, stats, timeout)


def get_cached_ngo_stats(ngo_id):
    """Get cached NGO statistics."""
    cache_key = f"ngo_stats:{ngo_id}"
    return cache.get(cache_key)


def invalidate_ngo_stats(ngo_id):
    """Invalidate NGO statistics cache."""
    cache_key = f"ngo_stats:{ngo_id}"
    cache.delete(cache_key)
