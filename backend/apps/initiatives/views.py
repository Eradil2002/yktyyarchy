from rest_framework import viewsets, permissions, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Initiative
from .serializers import InitiativeSerializer
from apps.users.search import search_initiatives

class InitiativeViewSet(viewsets.ModelViewSet):
    serializer_class = InitiativeSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'category', 'author']
    search_fields = ['title', 'description', 'category', 'location']
    ordering_fields = ['created_at', 'hours_claimed', 'title']
    ordering = ['-created_at']

    def get_queryset(self):
        queryset = Initiative.objects.select_related('author').order_by('-created_at')

        # Filter by date range
        date_from = self.request.query_params.get('date_from', None)
        date_to = self.request.query_params.get('date_to', None)

        if date_from:
            queryset = queryset.filter(created_at__gte=date_from)
        if date_to:
            queryset = queryset.filter(created_at__lte=date_to)

        return queryset

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAdminUser])
    def approve(self, request, pk=None):
        initiative = self.get_object()

        if initiative.hours_claimed <= 0 or initiative.hours_claimed > 100:
            return Response(
                {'detail': 'Invalid hours_claimed value'},
                status=status.HTTP_400_BAD_REQUEST
            )

        initiative.status = 'approved'
        initiative.save()
        
        # Add hours to user
        author = initiative.author
        author.total_hours += initiative.hours_claimed
        author.save()
        
        return Response({'status': 'approved', 'hours_added': initiative.hours_claimed})

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAdminUser])
    def reject(self, request, pk=None):
        initiative = self.get_object()
        initiative.status = 'rejected'
        initiative.save()
        return Response({'status': 'rejected'})

    @action(detail=False, methods=['get'], permission_classes=[permissions.AllowAny])
    def search(self, request):
        """
        Full-text search for initiatives.
        Query params: q (search query), category, status
        """
        query = request.query_params.get('q', '')

        filters = {}
        if request.query_params.get('category'):
            filters['category'] = request.query_params.get('category')
        if request.query_params.get('status'):
            filters['status'] = request.query_params.get('status')

        initiatives = search_initiatives(query, filters)

        page = self.paginate_queryset(initiatives)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(initiatives, many=True)
        return Response(serializer.data)
