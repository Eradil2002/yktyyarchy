"""
Global search view for searching across all models.
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions
from apps.users.search import global_search
from apps.events.serializers import EventSerializer
from apps.initiatives.serializers import InitiativeSerializer
from apps.users.serializers import UserSerializer


class GlobalSearchView(APIView):
    """
    Global search endpoint that searches across events, initiatives, and users.

    Query params:
        q: Search query string
        limit: Maximum results per model type (default: 10)
    """
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        query = request.query_params.get('q', '')
        limit = int(request.query_params.get('limit', 10))

        if not query:
            return Response({
                'detail': 'Search query is required',
                'events': [],
                'initiatives': [],
                'users': []
            })

        results = global_search(query, limit)

        # Serialize results
        response_data = {
            'query': query,
            'events': EventSerializer(results['events'], many=True, context={'request': request}).data,
            'initiatives': InitiativeSerializer(results['initiatives'], many=True, context={'request': request}).data,
            'users': UserSerializer(results['users'], many=True, context={'request': request}).data,
            'total_results': len(results['events']) + len(results['initiatives']) + len(results['users'])
        }

        return Response(response_data)
