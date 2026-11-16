# API Documentation Guide

## Overview
The volunteer platform API uses **drf-spectacular** to automatically generate OpenAPI 3.0 documentation with interactive Swagger UI and ReDoc interfaces.

## Accessing Documentation

### Swagger UI (Interactive)
**URL:** `http://localhost:8000/api/docs/`

Features:
- Interactive API testing
- Try out endpoints directly from browser
- View request/response examples
- Authentication support

### ReDoc (Read-only)
**URL:** `http://localhost:8000/api/redoc/`

Features:
- Clean, readable documentation
- Better for reading and understanding API
- Responsive design
- Search functionality

### OpenAPI Schema (JSON)
**URL:** `http://localhost:8000/api/schema/`

Features:
- Raw OpenAPI 3.0 schema
- Can be imported into Postman, Insomnia, etc.
- Used by code generators

## Configuration

Documentation is configured in `config/settings.py`:

```python
INSTALLED_APPS = [
    ...
    'drf_spectacular',
]

REST_FRAMEWORK = {
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

SPECTACULAR_SETTINGS = {
    'TITLE': 'Volunteer Platform API',
    'DESCRIPTION': 'API documentation for the volunteer platform',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'SCHEMA_PATH_PREFIX': '/api/v[0-9]',
    'COMPONENT_SPLIT_REQUEST': True,
}
```

## Customizing Documentation

### Adding Descriptions to ViewSets

```python
from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework import viewsets

@extend_schema_view(
    list=extend_schema(
        summary="List all events",
        description="Get a paginated list of all events with optional filtering",
        tags=['Events']
    ),
    retrieve=extend_schema(
        summary="Get event details",
        description="Retrieve detailed information about a specific event",
        tags=['Events']
    ),
    create=extend_schema(
        summary="Create new event",
        description="Create a new event (NGO users only)",
        tags=['Events']
    ),
)
class EventViewSet(viewsets.ModelViewSet):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
```

### Documenting Custom Actions

```python
from drf_spectacular.utils import extend_schema, OpenApiParameter
from rest_framework.decorators import action

class EventViewSet(viewsets.ModelViewSet):
    @extend_schema(
        summary="Register for event",
        description="Register the current user for this event",
        request=None,
        responses={201: EventRegistrationSerializer},
        tags=['Events', 'Registration']
    )
    @action(detail=True, methods=['post'])
    def register(self, request, pk=None):
        # Implementation
        pass

    @extend_schema(
        summary="Search events",
        description="Full-text search across events",
        parameters=[
            OpenApiParameter(
                name='q',
                type=str,
                location=OpenApiParameter.QUERY,
                description='Search query',
                required=True
            ),
            OpenApiParameter(
                name='category',
                type=str,
                location=OpenApiParameter.QUERY,
                description='Filter by category',
                required=False
            ),
        ],
        responses={200: EventSerializer(many=True)},
        tags=['Events', 'Search']
    )
    @action(detail=False, methods=['get'])
    def search(self, request):
        # Implementation
        pass
```

### Documenting Request/Response Examples

```python
from drf_spectacular.utils import extend_schema, OpenApiExample

@extend_schema(
    summary="Create event",
    examples=[
        OpenApiExample(
            'Valid event creation',
            value={
                'title': 'Beach Cleanup',
                'description': 'Help clean up the beach',
                'date': '2026-05-01T10:00:00Z',
                'location': 'Issyk-Kul Beach',
                'category': 'environment',
                'type': 'offline',
                'hours': 4,
                'spots_total': 20
            },
            request_only=True,
        ),
        OpenApiExample(
            'Created event response',
            value={
                'id': 1,
                'title': 'Beach Cleanup',
                'description': 'Help clean up the beach',
                'date': '2026-05-01T10:00:00Z',
                'organizer': 1,
                'status': 'open',
                'created_at': '2026-04-18T09:00:00Z'
            },
            response_only=True,
            status_codes=['201'],
        ),
    ]
)
def create(self, request):
    pass
```

### Documenting Authentication

```python
from drf_spectacular.utils import extend_schema

@extend_schema(
    summary="Get user profile",
    description="Retrieve the authenticated user's profile",
    auth=['Bearer'],  # Specify authentication method
    responses={
        200: UserSerializer,
        401: {'description': 'Authentication credentials were not provided'}
    }
)
def get_profile(self, request):
    pass
```

## Serializer Documentation

### Adding Field Descriptions

```python
from rest_framework import serializers

class EventSerializer(serializers.ModelSerializer):
    title = serializers.CharField(
        max_length=255,
        help_text="Event title (max 255 characters)"
    )
    date = serializers.DateTimeField(
        help_text="Event start date and time in ISO 8601 format"
    )
    spots_total = serializers.IntegerField(
        min_value=1,
        help_text="Total number of volunteer spots available"
    )

    class Meta:
        model = Event
        fields = '__all__'
```

### Documenting Nested Serializers

```python
class EventSerializer(serializers.ModelSerializer):
    organizer_details = UserSerializer(
        source='organizer',
        read_only=True,
        help_text="Detailed information about the event organizer"
    )
    
    class Meta:
        model = Event
        fields = '__all__'
```

## Grouping Endpoints with Tags

```python
@extend_schema(tags=['Events'])
class EventViewSet(viewsets.ModelViewSet):
    pass

@extend_schema(tags=['Users', 'Authentication'])
class RegisterView(generics.CreateAPIView):
    pass
```

## Excluding Endpoints from Documentation

```python
from drf_spectacular.utils import extend_schema

class InternalViewSet(viewsets.ModelViewSet):
    @extend_schema(exclude=True)
    @action(detail=False, methods=['get'])
    def internal_only(self, request):
        # This endpoint won't appear in documentation
        pass
```

## Custom Schema Generation

### Adding Global Parameters

```python
# config/settings.py
SPECTACULAR_SETTINGS = {
    'TITLE': 'Volunteer Platform API',
    'DESCRIPTION': 'API documentation for the volunteer platform',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'APPEND_COMPONENTS': {
        'securitySchemes': {
            'Bearer': {
                'type': 'http',
                'scheme': 'bearer',
                'bearerFormat': 'JWT',
            }
        }
    },
    'SECURITY': [{'Bearer': []}],
}
```

## Testing Documentation

### Validate Schema

```bash
# Generate schema and check for errors
python manage.py spectacular --file schema.yml --validate
```

### Export Schema

```bash
# Export to YAML
python manage.py spectacular --file schema.yml

# Export to JSON
python manage.py spectacular --file schema.json --format openapi-json
```

## Integration with Frontend

### TypeScript Code Generation

```bash
# Install openapi-typescript-codegen
npm install openapi-typescript-codegen --save-dev

# Generate TypeScript client
npx openapi-typescript-codegen --input http://localhost:8000/api/schema/ --output ./src/api
```

### Python Client Generation

```bash
# Install openapi-python-client
pip install openapi-python-client

# Generate Python client
openapi-python-client generate --url http://localhost:8000/api/schema/
```

## Best Practices

1. **Add descriptions to all endpoints**: Use `extend_schema` decorator
2. **Document query parameters**: Use `OpenApiParameter`
3. **Provide examples**: Use `OpenApiExample` for common use cases
4. **Group related endpoints**: Use tags for organization
5. **Document error responses**: Include all possible status codes
6. **Keep descriptions concise**: Focus on what, not how
7. **Update documentation with code**: Keep docs in sync with implementation

## Common Patterns

### Pagination Documentation

```python
@extend_schema(
    parameters=[
        OpenApiParameter('page', int, description='Page number'),
        OpenApiParameter('page_size', int, description='Items per page'),
    ]
)
def list(self, request):
    pass
```

### Filtering Documentation

```python
@extend_schema(
    parameters=[
        OpenApiParameter('category', str, description='Filter by category'),
        OpenApiParameter('status', str, description='Filter by status'),
        OpenApiParameter('date_from', str, description='Filter events from date'),
        OpenApiParameter('date_to', str, description='Filter events to date'),
    ]
)
def list(self, request):
    pass
```

### File Upload Documentation

```python
from drf_spectacular.types import OpenApiTypes

@extend_schema(
    request={
        'multipart/form-data': {
            'type': 'object',
            'properties': {
                'file': {
                    'type': 'string',
                    'format': 'binary'
                }
            }
        }
    }
)
def upload(self, request):
    pass
```

## Troubleshooting

### Schema Generation Errors

If schema generation fails:

1. Check for circular imports
2. Ensure all serializers are properly defined
3. Validate custom schema extensions
4. Check for missing `extend_schema` decorators on custom actions

### Missing Endpoints

If endpoints don't appear in documentation:

1. Ensure ViewSet is registered in router
2. Check if endpoint is excluded with `extend_schema(exclude=True)`
3. Verify URL patterns are correct
4. Check `SCHEMA_PATH_PREFIX` setting

## Resources

- drf-spectacular Documentation: https://drf-spectacular.readthedocs.io/
- OpenAPI Specification: https://swagger.io/specification/
- Swagger UI: https://swagger.io/tools/swagger-ui/
- ReDoc: https://redocly.com/redoc/
