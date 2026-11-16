# Bulk Operations Guide

## Overview
Bulk operations allow you to create, update, or delete multiple records in a single API request, improving efficiency and reducing network overhead.

## Available Operations

### 1. Bulk Create
Create multiple records at once.

**Endpoint:** `POST /api/v1/{resource}/bulk-create/`

**Request:**
```json
{
  "items": [
    {
      "title": "Event 1",
      "description": "Description 1",
      "date": "2026-05-01T10:00:00Z"
    },
    {
      "title": "Event 2",
      "description": "Description 2",
      "date": "2026-05-02T10:00:00Z"
    }
  ]
}
```

**Response (201 Created):**
```json
{
  "detail": "Successfully created 2 items",
  "created": [
    {
      "id": 1,
      "title": "Event 1",
      "description": "Description 1",
      "date": "2026-05-01T10:00:00Z"
    },
    {
      "id": 2,
      "title": "Event 2",
      "description": "Description 2",
      "date": "2026-05-02T10:00:00Z"
    }
  ]
}
```

### 2. Bulk Update
Update multiple records at once.

**Endpoint:** `PATCH /api/v1/{resource}/bulk-update/`

**Request:**
```json
{
  "items": [
    {
      "id": 1,
      "title": "Updated Event 1"
    },
    {
      "id": 2,
      "status": "completed"
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "detail": "Successfully updated 2 items",
  "updated": [
    {
      "id": 1,
      "title": "Updated Event 1",
      "description": "Description 1",
      "date": "2026-05-01T10:00:00Z"
    },
    {
      "id": 2,
      "title": "Event 2",
      "description": "Description 2",
      "status": "completed",
      "date": "2026-05-02T10:00:00Z"
    }
  ]
}
```

### 3. Bulk Delete
Delete multiple records at once.

**Endpoint:** `POST /api/v1/{resource}/bulk-delete/`

**Request:**
```json
{
  "ids": [1, 2, 3, 4, 5]
}
```

**Response (200 OK):**
```json
{
  "detail": "Successfully deleted 5 items",
  "deleted_count": 5
}
```

## Implementation

### Adding Bulk Operations to ViewSets

```python
from rest_framework import viewsets
from apps.users.bulk_operations import BulkOperationsMixin

class EventViewSet(BulkOperationsMixin, viewsets.ModelViewSet):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    
    # Now has bulk_create, bulk_update, bulk_delete actions
```

### Using Individual Mixins

```python
from apps.users.bulk_operations import BulkCreateMixin, BulkUpdateMixin

class EventViewSet(BulkCreateMixin, BulkUpdateMixin, viewsets.ModelViewSet):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    
    # Only has bulk_create and bulk_update
```

## Limitations

- **Maximum items per request:** 100
- **Transaction safety:** All operations are atomic (all succeed or all fail)
- **Permissions:** Same permissions as individual create/update/delete operations

## Error Handling

### Validation Errors

If any item fails validation, the entire operation is rolled back:

```json
{
  "detail": "Bulk create failed",
  "errors": [
    {
      "index": 0,
      "errors": {
        "title": ["This field is required"]
      }
    },
    {
      "index": 2,
      "errors": {
        "date": ["Invalid date format"]
      }
    }
  ]
}
```

### Not Found Errors (Bulk Update)

```json
{
  "detail": "Bulk update failed",
  "errors": [
    {
      "index": 1,
      "id": 999,
      "errors": {
        "detail": "Not found"
      }
    }
  ]
}
```

## Use Cases

### 1. Importing Data
Import multiple records from CSV or external API:

```python
import requests

def import_events(events_data):
    response = requests.post(
        'https://api.example.com/api/v1/events/bulk-create/',
        json={'items': events_data},
        headers={'Authorization': 'Bearer YOUR_TOKEN'}
    )
    return response.json()
```

### 2. Batch Status Updates
Update status of multiple events:

```python
def close_past_events(event_ids):
    items = [{'id': id, 'status': 'closed'} for id in event_ids]
    response = requests.patch(
        'https://api.example.com/api/v1/events/bulk-update/',
        json={'items': items},
        headers={'Authorization': 'Bearer YOUR_TOKEN'}
    )
    return response.json()
```

### 3. Cleanup Operations
Delete multiple old records:

```python
def cleanup_old_notifications(notification_ids):
    response = requests.post(
        'https://api.example.com/api/v1/notifications/bulk-delete/',
        json={'ids': notification_ids},
        headers={'Authorization': 'Bearer YOUR_TOKEN'}
    )
    return response.json()
```

## Client Examples

### JavaScript/TypeScript

```typescript
async function bulkCreateEvents(events: Event[]): Promise<BulkResponse> {
  const response = await fetch('/api/v1/events/bulk-create/', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ items: events })
  });
  
  return response.json();
}

async function bulkUpdateEvents(updates: Partial<Event>[]): Promise<BulkResponse> {
  const response = await fetch('/api/v1/events/bulk-update/', {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ items: updates })
  });
  
  return response.json();
}

async function bulkDeleteEvents(ids: number[]): Promise<BulkResponse> {
  const response = await fetch('/api/v1/events/bulk-delete/', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ ids })
  });
  
  return response.json();
}
```

### Python

```python
import requests

class APIClient:
    def __init__(self, base_url, token):
        self.base_url = base_url
        self.headers = {'Authorization': f'Bearer {token}'}
    
    def bulk_create(self, resource, items):
        url = f'{self.base_url}/api/v1/{resource}/bulk-create/'
        response = requests.post(url, json={'items': items}, headers=self.headers)
        return response.json()
    
    def bulk_update(self, resource, items):
        url = f'{self.base_url}/api/v1/{resource}/bulk-update/'
        response = requests.patch(url, json={'items': items}, headers=self.headers)
        return response.json()
    
    def bulk_delete(self, resource, ids):
        url = f'{self.base_url}/api/v1/{resource}/bulk-delete/'
        response = requests.post(url, json={'ids': ids}, headers=self.headers)
        return response.json()
```

### Dart/Flutter

```dart
class ApiClient {
  final String baseUrl;
  final String token;
  
  ApiClient(this.baseUrl, this.token);
  
  Future<BulkResponse> bulkCreate(String resource, List<Map<String, dynamic>> items) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/$resource/bulk-create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'items': items}),
    );
    
    return BulkResponse.fromJson(jsonDecode(response.body));
  }
  
  Future<BulkResponse> bulkUpdate(String resource, List<Map<String, dynamic>> items) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/v1/$resource/bulk-update/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'items': items}),
    );
    
    return BulkResponse.fromJson(jsonDecode(response.body));
  }
  
  Future<BulkResponse> bulkDelete(String resource, List<int> ids) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/$resource/bulk-delete/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'ids': ids}),
    );
    
    return BulkResponse.fromJson(jsonDecode(response.body));
  }
}
```

## Performance Considerations

### Benefits
- Reduces number of HTTP requests
- Reduces network latency
- Atomic transactions ensure data consistency
- Better for batch operations

### Trade-offs
- Larger request/response payloads
- Longer processing time per request
- All-or-nothing approach (one failure rolls back all)

### Best Practices
1. **Batch size:** Keep batches under 100 items
2. **Validation:** Validate data client-side before sending
3. **Error handling:** Handle partial failures gracefully
4. **Progress tracking:** For large batches, split into multiple requests
5. **Timeouts:** Increase timeout for bulk operations

## Security Considerations

1. **Rate limiting:** Bulk operations count as single requests
2. **Permissions:** Each item is checked against user permissions
3. **Input validation:** All items are validated before processing
4. **Transaction safety:** Failed operations are rolled back

## Testing

```python
from django.test import TestCase
from rest_framework.test import APIClient

class BulkOperationsTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
    
    def test_bulk_create(self):
        data = {
            'items': [
                {'title': 'Event 1', 'date': '2026-05-01T10:00:00Z'},
                {'title': 'Event 2', 'date': '2026-05-02T10:00:00Z'},
            ]
        }
        response = self.client.post('/api/v1/events/bulk-create/', data, format='json')
        self.assertEqual(response.status_code, 201)
        self.assertEqual(len(response.data['created']), 2)
    
    def test_bulk_update(self):
        # Create events first
        event1 = Event.objects.create(title='Event 1')
        event2 = Event.objects.create(title='Event 2')
        
        data = {
            'items': [
                {'id': event1.id, 'title': 'Updated 1'},
                {'id': event2.id, 'title': 'Updated 2'},
            ]
        }
        response = self.client.patch('/api/v1/events/bulk-update/', data, format='json')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data['updated']), 2)
    
    def test_bulk_delete(self):
        event1 = Event.objects.create(title='Event 1')
        event2 = Event.objects.create(title='Event 2')
        
        data = {'ids': [event1.id, event2.id]}
        response = self.client.post('/api/v1/events/bulk-delete/', data, format='json')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['deleted_count'], 2)
```

## Resources

- Django Transactions: https://docs.djangoproject.com/en/5.0/topics/db/transactions/
- DRF Serializers: https://www.django-rest-framework.org/api-guide/serializers/
- Bulk Operations Best Practices: https://restfulapi.net/bulk-operations/
