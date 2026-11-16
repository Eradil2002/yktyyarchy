# Query Optimization Guide

## Overview
This document outlines query optimization strategies implemented in the volunteer platform to prevent N+1 queries and improve database performance.

## N+1 Query Problem

The N+1 query problem occurs when:
1. You fetch N records from the database
2. For each record, you make an additional query to fetch related data
3. This results in 1 + N queries instead of 1 or 2 optimized queries

## Solutions Implemented

### 1. select_related() for Foreign Keys

Use `select_related()` for single-valued relationships (ForeignKey, OneToOneField).

**Already implemented in:**

```python
# apps/events/views.py
queryset = Event.objects.select_related('organizer').prefetch_related('registrations')

# apps/initiatives/views.py
queryset = Initiative.objects.select_related('author').order_by('-created_at')

# apps/events/views.py - my_registrations action
queryset = EventRegistration.objects.filter(volunteer=request.user).select_related('event', 'event__organizer')
```

### 2. prefetch_related() for Reverse Foreign Keys and Many-to-Many

Use `prefetch_related()` for multi-valued relationships (reverse ForeignKey, ManyToManyField).

**Already implemented in:**

```python
# apps/events/views.py
queryset = Event.objects.select_related('organizer').prefetch_related('registrations')
```

### 3. Additional Optimizations Needed

#### Reviews ViewSet

```python
# apps/reviews/views.py
class ReviewViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        return Review.objects.select_related(
            'reviewer',
            'target_user',
            'event',
            'moderated_by'
        ).order_by('-created_at')
```

#### User ViewSet

```python
# apps/users/views.py
class UserViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        return CustomUser.objects.select_related(
            'volunteer_profile',
            'ngo_profile'
        ).prefetch_related(
            'organized_events',
            'initiatives',
            'reviews_received'
        )
```

#### Notifications ViewSet

```python
# apps/notifications/views.py
class NotificationViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        return Notification.objects.select_related(
            'user',
            'event'
        ).order_by('-created_at')
```

## Query Analysis Tools

### Django Debug Toolbar

Install for development:

```bash
pip install django-debug-toolbar
```

Add to settings.py:

```python
if DEBUG:
    INSTALLED_APPS += ['debug_toolbar']
    MIDDLEWARE += ['debug_toolbar.middleware.DebugToolbarMiddleware']
    INTERNAL_IPS = ['127.0.0.1']
```

### Query Logging

Enable query logging in settings.py:

```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
    },
}
```

### Manual Query Counting

```python
from django.db import connection
from django.test.utils import override_settings

@override_settings(DEBUG=True)
def test_query_count():
    connection.queries_log.clear()
    
    # Your code here
    events = Event.objects.all()
    for event in events:
        print(event.organizer.username)
    
    print(f"Number of queries: {len(connection.queries)}")
```

## Best Practices

### 1. Use only() and defer() Sparingly

```python
# Fetch only specific fields
events = Event.objects.only('id', 'title', 'date')

# Defer large fields
events = Event.objects.defer('description', 'requirements')
```

### 2. Use values() and values_list() for Simple Data

```python
# Get list of tuples
event_ids = Event.objects.values_list('id', flat=True)

# Get list of dictionaries
event_data = Event.objects.values('id', 'title', 'date')
```

### 3. Use Prefetch Objects for Complex Queries

```python
from django.db.models import Prefetch

# Custom prefetch with filtering
approved_registrations = EventRegistration.objects.filter(status='approved')

events = Event.objects.prefetch_related(
    Prefetch('registrations', queryset=approved_registrations, to_attr='approved_regs')
)
```

### 4. Use annotate() for Aggregations

```python
from django.db.models import Count, Avg

# Annotate with counts
events = Event.objects.annotate(
    registration_count=Count('registrations'),
    avg_rating=Avg('reviews__rating')
)
```

### 5. Use Database Indexes

Already implemented in migrations:
- `events/migrations/0003_add_indexes.py`
- `initiatives/migrations/0003_add_indexes.py`
- `notifications/migrations/0002_add_indexes.py`
- `users/migrations/0002_add_indexes.py`

## Common Patterns

### Pattern 1: List View with Related Data

```python
def list(self, request):
    queryset = self.get_queryset().select_related(
        'foreign_key_field'
    ).prefetch_related(
        'reverse_fk_or_m2m_field'
    )
    
    page = self.paginate_queryset(queryset)
    serializer = self.get_serializer(page, many=True)
    return self.get_paginated_response(serializer.data)
```

### Pattern 2: Detail View with Nested Data

```python
def retrieve(self, request, pk=None):
    instance = self.get_queryset().select_related(
        'foreign_key_1',
        'foreign_key_2'
    ).prefetch_related(
        'related_set_1',
        'related_set_2__nested_relation'
    ).get(pk=pk)
    
    serializer = self.get_serializer(instance)
    return Response(serializer.data)
```

### Pattern 3: Custom Action with Filtering

```python
@action(detail=False, methods=['get'])
def my_custom_action(self, request):
    queryset = Model.objects.filter(
        user=request.user
    ).select_related(
        'related_model'
    ).prefetch_related(
        'many_to_many_field'
    )
    
    serializer = self.get_serializer(queryset, many=True)
    return Response(serializer.data)
```

## Performance Monitoring

### 1. Track Query Count per Endpoint

```python
from django.db import connection
from django.utils.deprecation import MiddlewareMixin

class QueryCountMiddleware(MiddlewareMixin):
    def process_response(self, request, response):
        if settings.DEBUG:
            query_count = len(connection.queries)
            print(f"{request.path}: {query_count} queries")
        return response
```

### 2. Set Query Count Limits in Tests

```python
from django.test import TestCase
from django.test.utils import override_settings

class EventViewTestCase(TestCase):
    def test_event_list_query_count(self):
        with self.assertNumQueries(3):  # Expect exactly 3 queries
            response = self.client.get('/api/v1/events/')
            self.assertEqual(response.status_code, 200)
```

## Checklist

- [x] Events ViewSet uses select_related('organizer')
- [x] Events ViewSet uses prefetch_related('registrations')
- [x] Initiatives ViewSet uses select_related('author')
- [x] EventRegistration queries use select_related('event', 'event__organizer')
- [ ] Reviews ViewSet optimized with select_related
- [ ] Users ViewSet optimized with select_related and prefetch_related
- [ ] Notifications ViewSet optimized with select_related
- [ ] Database indexes created for frequently queried fields
- [ ] Query logging enabled in development
- [ ] Performance tests added for critical endpoints

## Resources

- Django QuerySet API: https://docs.djangoproject.com/en/5.0/ref/models/querysets/
- Django Database Optimization: https://docs.djangoproject.com/en/5.0/topics/db/optimization/
- select_related vs prefetch_related: https://docs.djangoproject.com/en/5.0/ref/models/querysets/#select-related
