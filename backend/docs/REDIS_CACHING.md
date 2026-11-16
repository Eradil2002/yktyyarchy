# Redis Caching Implementation Guide

## Overview
This guide explains how to use Redis caching in the volunteer platform to improve performance and reduce database load.

## Installation

Redis caching has been configured with the following packages:
- `django-redis==5.4.0` - Django Redis cache backend
- `hiredis==2.3.2` - High-performance Redis parser

## Configuration

Cache settings are configured in `config/settings.py`:

```python
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://localhost:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'PARSER_CLASS': 'redis.connection.HiredisParser',
            'CONNECTION_POOL_KWARGS': {
                'max_connections': 50,
                'retry_on_timeout': True,
            },
        },
        'KEY_PREFIX': 'volunteer_platform',
        'TIMEOUT': 300,  # 5 minutes default
    }
}
```

## Usage Examples

### 1. Using the Cache Decorator

```python
from apps.users.cache_utils import cache_result

@cache_result(timeout=3600, key_prefix='user_stats')
def get_user_statistics(user_id):
    # Expensive database queries
    stats = {
        'total_hours': user.total_hours,
        'events_attended': user.events_attended,
        'rating': user.average_rating,
    }
    return stats
```

### 2. Manual Cache Operations

```python
from django.core.cache import cache

# Set cache
cache.set('my_key', my_value, timeout=300)

# Get cache
value = cache.get('my_key')

# Delete cache
cache.delete('my_key')

# Get or set (atomic operation)
value = cache.get_or_set('my_key', default_value, timeout=300)
```

### 3. Using Helper Functions

```python
from apps.users.cache_utils import (
    cache_user_stats,
    get_cached_user_stats,
    invalidate_user_stats,
)

# Cache user stats
stats = calculate_user_stats(user_id)
cache_user_stats(user_id, stats)

# Get cached stats
cached_stats = get_cached_user_stats(user_id)
if cached_stats is None:
    # Cache miss - calculate and cache
    stats = calculate_user_stats(user_id)
    cache_user_stats(user_id, stats)

# Invalidate when data changes
invalidate_user_stats(user_id)
```

## Cache Invalidation Strategy

### When to Invalidate Cache

1. **User Stats**: Invalidate when:
   - User completes an event
   - User receives a review
   - User's hours are updated

2. **Event List**: Invalidate when:
   - New event is created
   - Event is updated or deleted
   - Event status changes

3. **Leaderboard**: Invalidate when:
   - Any user's hours change
   - New achievements are earned

### Example: Invalidate on Model Save

```python
from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.users.cache_utils import invalidate_user_stats, invalidate_leaderboard

@receiver(post_save, sender=EventRegistration)
def invalidate_caches_on_registration(sender, instance, **kwargs):
    if instance.status == 'attended':
        # Invalidate user stats
        invalidate_user_stats(instance.volunteer.id)
        
        # Invalidate leaderboard
        invalidate_leaderboard()
```

## Caching in Views

### Example: Cached Event List

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from apps.users.cache_utils import get_cached_event_list, cache_event_list

class EventListView(APIView):
    def get(self, request):
        filters = {
            'category': request.GET.get('category'),
            'status': request.GET.get('status', 'open'),
        }
        
        # Try to get from cache
        cached_events = get_cached_event_list(filters)
        if cached_events is not None:
            return Response(cached_events)
        
        # Cache miss - query database
        events = Event.objects.filter(**filters)
        serializer = EventSerializer(events, many=True)
        
        # Cache the result
        cache_event_list(filters, serializer.data, timeout=300)
        
        return Response(serializer.data)
```

### Example: Cached User Profile

```python
from django.views.decorators.cache import cache_page
from django.utils.decorators import method_decorator

class UserProfileView(APIView):
    @method_decorator(cache_page(60 * 15))  # Cache for 15 minutes
    def get(self, request, user_id):
        user = get_object_or_404(CustomUser, id=user_id)
        serializer = UserProfileSerializer(user)
        return Response(serializer.data)
```

## Cache Timeouts

Recommended cache timeouts (configured in `settings.CACHE_TTL`):

- **User Stats**: 1 hour (3600s)
- **Event List**: 5 minutes (300s)
- **Event Detail**: 10 minutes (600s)
- **Leaderboard**: 30 minutes (1800s)
- **NGO Stats**: 1 hour (3600s)

## Monitoring Cache Performance

### Check Cache Hit Rate

```python
from django.core.cache import cache

# Get cache statistics (requires django-redis)
stats = cache.client.get_client().info('stats')
print(f"Hits: {stats.get('keyspace_hits', 0)}")
print(f"Misses: {stats.get('keyspace_misses', 0)}")
```

### Clear All Cache

```python
from django.core.cache import cache

# Clear all cache
cache.clear()
```

## Best Practices

1. **Use Appropriate Timeouts**: Don't cache data that changes frequently
2. **Invalidate Proactively**: Clear cache when underlying data changes
3. **Use Key Prefixes**: Organize cache keys by feature/model
4. **Monitor Cache Size**: Ensure Redis has enough memory
5. **Handle Cache Failures**: Always have fallback to database queries
6. **Avoid Caching User-Specific Data**: Unless using per-user cache keys

## Environment Variables

Add to `.env`:

```env
# Redis Configuration
REDIS_URL=redis://localhost:6379/1
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0
```

## Testing Cache

```python
from django.test import TestCase
from django.core.cache import cache

class CacheTestCase(TestCase):
    def setUp(self):
        cache.clear()
    
    def test_user_stats_caching(self):
        user_id = 1
        stats = {'hours': 10}
        
        # Cache stats
        cache_user_stats(user_id, stats)
        
        # Retrieve from cache
        cached = get_cached_user_stats(user_id)
        self.assertEqual(cached, stats)
        
        # Invalidate
        invalidate_user_stats(user_id)
        cached = get_cached_user_stats(user_id)
        self.assertIsNone(cached)
```

## Production Considerations

1. **Redis Persistence**: Configure RDB or AOF persistence
2. **Memory Limits**: Set `maxmemory` and eviction policy
3. **Replication**: Use Redis Sentinel or Cluster for high availability
4. **Monitoring**: Use Redis monitoring tools (RedisInsight, Prometheus)
5. **Security**: Enable authentication with `requirepass`

## Redis Configuration (redis.conf)

```conf
# Memory
maxmemory 2gb
maxmemory-policy allkeys-lru

# Persistence
save 900 1
save 300 10
save 60 10000

# Security
requirepass your_redis_password

# Performance
tcp-backlog 511
timeout 0
tcp-keepalive 300
```
