# API Versioning Guide

## Overview
The volunteer platform API uses URL path versioning to manage different API versions. This allows us to introduce breaking changes while maintaining backward compatibility.

## Versioning Strategy

### Current Version: v1
- Base URL: `/api/v1/`
- Default version for all endpoints
- Stable and production-ready

### Future Version: v2
- Base URL: `/api/v2/`
- Reserved for future breaking changes
- Not yet implemented

## Configuration

API versioning is configured in `config/settings.py`:

```python
REST_FRAMEWORK = {
    'DEFAULT_VERSIONING_CLASS': 'apps.users.versioning.APIVersioning',
    'DEFAULT_VERSION': 'v1',
    'ALLOWED_VERSIONS': ['v1', 'v2'],
}
```

## URL Structure

All API endpoints follow this pattern:

```
/api/{version}/{resource}/
```

Examples:
- `/api/v1/events/` - List all events (v1)
- `/api/v1/events/123/` - Get event detail (v1)
- `/api/v2/events/` - List all events (v2, future)

## Accessing API Version in Views

```python
from rest_framework.views import APIView
from rest_framework.response import Response

class MyView(APIView):
    def get(self, request):
        version = request.version
        
        if version == 'v1':
            # v1 logic
            return Response({'version': 'v1', 'data': []})
        elif version == 'v2':
            # v2 logic with breaking changes
            return Response({'version': 'v2', 'data': []})
```

## Versioning in Serializers

```python
from rest_framework import serializers

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = '__all__'
    
    def to_representation(self, instance):
        data = super().to_representation(instance)
        
        # Version-specific modifications
        if self.context.get('request').version == 'v2':
            # Add new fields or modify structure for v2
            data['new_field'] = 'v2 only'
        
        return data
```

## Migration Strategy

### When to Create a New Version

Create a new API version when:
1. Removing fields from responses
2. Changing field types or formats
3. Changing URL structure
4. Modifying authentication/authorization logic
5. Changing error response formats

### When NOT to Create a New Version

Don't create a new version for:
1. Adding new optional fields
2. Adding new endpoints
3. Bug fixes
4. Performance improvements
5. Adding new query parameters

## Example: Migrating from v1 to v2

### Step 1: Create v2 URLs

```python
# config/urls.py
from django.urls import path, include

urlpatterns = [
    # v1 endpoints (existing)
    path('api/v1/events/', include('apps.events.urls', namespace='v1')),
    
    # v2 endpoints (new)
    path('api/v2/events/', include('apps.events.urls_v2', namespace='v2')),
]
```

### Step 2: Create v2 Serializers

```python
# apps/events/serializers_v2.py
from rest_framework import serializers
from .models import Event

class EventSerializerV2(serializers.ModelSerializer):
    # Breaking change: rename field
    event_date = serializers.DateTimeField(source='date')
    
    class Meta:
        model = Event
        fields = ['id', 'title', 'event_date', 'location']  # Removed some fields
```

### Step 3: Create v2 Views

```python
# apps/events/views_v2.py
from rest_framework import viewsets
from .models import Event
from .serializers_v2 import EventSerializerV2

class EventViewSetV2(viewsets.ModelViewSet):
    queryset = Event.objects.all()
    serializer_class = EventSerializerV2
```

### Step 4: Update Documentation

Document all breaking changes:
- Field renames
- Removed fields
- Changed response formats
- New validation rules

## Deprecation Policy

### Timeline

1. **Announcement** (T+0): Announce deprecation of old version
2. **Deprecation Period** (T+6 months): Both versions supported
3. **Sunset** (T+12 months): Old version removed

### Deprecation Headers

Add deprecation warnings to responses:

```python
from rest_framework.response import Response

class MyView(APIView):
    def get(self, request):
        response = Response({'data': []})
        
        if request.version == 'v1':
            response['Warning'] = '299 - "API v1 is deprecated. Please migrate to v2 by 2027-01-01"'
            response['Sunset'] = 'Sat, 01 Jan 2027 00:00:00 GMT'
        
        return response
```

## Version-Specific Features

### v1 Features
- All current endpoints
- Current field names and formats
- Existing authentication flow

### v2 Features (Planned)
- Improved response structure
- Consistent error formats
- Enhanced filtering options
- GraphQL support (optional)

## Testing Different Versions

```python
from django.test import TestCase
from rest_framework.test import APIClient

class EventAPITestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
    
    def test_v1_endpoint(self):
        response = self.client.get('/api/v1/events/')
        self.assertEqual(response.status_code, 200)
    
    def test_v2_endpoint(self):
        response = self.client.get('/api/v2/events/')
        self.assertEqual(response.status_code, 200)
```

## Client Implementation

### JavaScript/TypeScript

```javascript
const API_BASE_URL = 'https://api.example.com';
const API_VERSION = 'v1';

async function getEvents() {
    const response = await fetch(`${API_BASE_URL}/api/${API_VERSION}/events/`);
    return response.json();
}
```

### Python

```python
import requests

API_BASE_URL = 'https://api.example.com'
API_VERSION = 'v1'

def get_events():
    response = requests.get(f'{API_BASE_URL}/api/{API_VERSION}/events/')
    return response.json()
```

### Dart/Flutter

```dart
class ApiClient {
  static const String baseUrl = 'https://api.example.com';
  static const String version = 'v1';
  
  Future<List<Event>> getEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/$version/events/')
    );
    return parseEvents(response.body);
  }
}
```

## Best Practices

1. **Always specify version in URLs**: Don't rely on default version
2. **Document breaking changes**: Maintain a changelog for each version
3. **Test both versions**: Ensure v1 continues working when v2 is added
4. **Use feature flags**: Gradually roll out v2 features
5. **Monitor usage**: Track which versions are being used
6. **Communicate early**: Give users advance notice of deprecations

## Monitoring Version Usage

```python
from django.utils.deprecation import MiddlewareMixin

class APIVersionMiddleware(MiddlewareMixin):
    def process_request(self, request):
        if request.path.startswith('/api/'):
            version = request.path.split('/')[2]  # Extract version from URL
            # Log version usage for analytics
            print(f"API {version} accessed: {request.path}")
```

## Resources

- DRF Versioning: https://www.django-rest-framework.org/api-guide/versioning/
- API Versioning Best Practices: https://restfulapi.net/versioning/
- Semantic Versioning: https://semver.org/
