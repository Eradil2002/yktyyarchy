from apps.users.permissions import IsOwnerOrReadOnly
import math
from rest_framework import viewsets, permissions, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from django_filters.rest_framework import DjangoFilterBackend
from .models import Event, EventRegistration
from .serializers import EventSerializer, EventRegistrationSerializer
from .duplicate_checker import check_duplicate_events
from .qr_utils import generate_event_qr_code
from .statistics import get_ngo_statistics, get_event_statistics
from .recommendations import get_recommended_events, get_similar_events, get_popular_events
from .geofencing import check_auto_attendance, get_nearby_events
from .calendar_utils import get_events_by_month, get_events_by_week, get_calendar_summary
from apps.users.search import search_events

def haversine(lat1, lon1, lat2, lon2):
    """Calculate the great circle distance between two points in km."""
    try:
        if lat1 is None or lon1 is None or lat2 is None or lon2 is None:
            return float('inf')
        
        R = 6371  # Earth radius in km
        phi1, phi2 = math.radians(lat1), math.radians(lat2)
        dphi = math.radians(lat2 - lat1)
        dlambda = math.radians(lon2 - lon1)
        
        a = math.sin(dphi / 2)**2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return R * c
    except Exception:
        return float('inf')

class IsNGOOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user.is_authenticated and request.user.role == 'ngo'


class EventViewSet(viewsets.ModelViewSet):
    serializer_class = EventSerializer
    # NGO role to create; only the organizer (or staff) may edit/delete
    permission_classes = [IsNGOOrReadOnly, IsOwnerOrReadOnly]
    owner_field = 'organizer'
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'type', 'status', 'is_urgent', 'organizer']
    search_fields = ['title', 'description', 'location', 'category']
    ordering_fields = ['date', 'created_at', 'hours', 'spots_total']
    ordering = ['-date']

    def get_queryset(self):
        queryset = Event.objects.select_related('organizer').prefetch_related('registrations')

        # Date filtering
        date_param = self.request.query_params.get('date')
        if date_param:
            if date_param == 'today':
                today = timezone.now().date()
                queryset = queryset.filter(date__date=today)
            else:
                queryset = queryset.filter(date__date=date_param)

        # Date range filtering
        date_from = self.request.query_params.get('date_from')
        date_to = self.request.query_params.get('date_to')
        if date_from:
            queryset = queryset.filter(date__gte=date_from)
        if date_to:
            queryset = queryset.filter(date__lte=date_to)

        # Proximity sorting
        user_lat = self.request.query_params.get('lat')
        user_lng = self.request.query_params.get('lng')
        
        if user_lat and user_lng:
            try:
                u_lat = float(user_lat)
                u_lng = float(user_lng)
                
                # We convert to list to sort by distance in Python
                events = list(queryset)
                events.sort(key=lambda x: haversine(u_lat, u_lng, x.latitude, x.longitude))
                return events
            except (ValueError, TypeError):
                pass
                
        return queryset.order_by('-date')

    def perform_create(self, serializer):
        serializer.save(organizer=self.request.user)

    @action(detail=False, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def check_duplicates(self, request):
        """
        Check for potential duplicate events before creating.
        POST data: title, date, location, category (optional)
        """
        title = request.data.get('title')
        date = request.data.get('date')
        location = request.data.get('location')
        category = request.data.get('category')

        if not all([title, date, location]):
            return Response(
                {'detail': 'title, date и location обязательны'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Parse date
        from dateutil import parser
        try:
            parsed_date = parser.parse(date)
        except:
            return Response(
                {'detail': 'Неверный формат даты'},
                status=status.HTTP_400_BAD_REQUEST
            )

        duplicates = check_duplicate_events(
            title=title,
            date=parsed_date,
            location=location,
            organizer=request.user,
            category=category
        )

        return Response({
            'has_duplicates': len(duplicates) > 0,
            'duplicates': duplicates
        })

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def register(self, request, pk=None):
        event = self.get_object()
        user = request.user

        # Check if event is open for registration
        if event.status != 'open':
            return Response({"detail": "Регистрация на это мероприятие закрыта"}, status=status.HTTP_400_BAD_REQUEST)

        # Check if event is in the past
        if event.date < timezone.now():
            return Response({"detail": "Это мероприятие уже прошло"}, status=status.HTTP_400_BAD_REQUEST)

        if event.spots_booked >= event.spots_total:
            return Response({"detail": "Нет свободных мест"}, status=status.HTTP_400_BAD_REQUEST)

        if EventRegistration.objects.filter(event=event, volunteer=user).exists():
            return Response({"detail": "Вы уже зарегистрированы"}, status=status.HTTP_400_BAD_REQUEST)

        registration = EventRegistration.objects.create(event=event, volunteer=user)
        return Response(EventRegistrationSerializer(registration).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['delete'], permission_classes=[permissions.IsAuthenticated])
    def unregister(self, request, pk=None):
        event = self.get_object()
        user = request.user
        
        try:
            registration = EventRegistration.objects.get(event=event, volunteer=user)
            registration.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except EventRegistration.DoesNotExist:
            return Response({"detail": "Вы не были зарегистрированы"}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def generate_qr(self, request, pk=None):
        """
        Generate QR code for event registration.
        Only event organizer can generate QR code.
        """
        event = self.get_object()

        # Check if user is the organizer
        if event.organizer != request.user:
            return Response(
                {"detail": "Только организатор может генерировать QR-код"},
                status=status.HTTP_403_FORBIDDEN
            )

        # Generate QR code
        qr_image = generate_event_qr_code(event)
        event.qr_code.save(qr_image.name, qr_image, save=True)

        return Response({
            'detail': 'QR-код успешно сгенерирован',
            'qr_code_url': event.qr_code.url if event.qr_code else None
        })

    @action(detail=False, methods=['get'], url_path='my-registrations', permission_classes=[permissions.IsAuthenticated])
    def my_registrations(self, request):
        queryset = EventRegistration.objects.filter(volunteer=request.user).select_related('event', 'event__organizer')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = EventRegistrationSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = EventRegistrationSerializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='ngo-statistics', permission_classes=[permissions.IsAuthenticated])
    def ngo_statistics(self, request):
        """
        Get comprehensive statistics for NGO dashboard.
        Only available for users with role='ngo'.
        """
        if request.user.role != 'ngo':
            return Response(
                {"detail": "Доступно только для НКО"},
                status=status.HTTP_403_FORBIDDEN
            )

        stats = get_ngo_statistics(request.user)
        return Response(stats)

    @action(detail=True, methods=['get'], url_path='statistics', url_name='statistics', permission_classes=[permissions.IsAuthenticated])
    def event_statistics(self, request, pk=None):
        """
        Get statistics for a specific event.
        Only event organizer can view statistics.
        """
        event = self.get_object()

        # Check if user is the organizer
        if event.organizer != request.user and not request.user.is_staff:
            return Response(
                {"detail": "Только организатор может просматривать статистику"},
                status=status.HTTP_403_FORBIDDEN
            )

        stats = get_event_statistics(event)
        return Response(stats)

    @action(detail=False, methods=['get'], url_path='recommended', permission_classes=[permissions.IsAuthenticated])
    def recommended(self, request):
        """
        Get personalized event recommendations for the current user.
        Based on user's past participation, skills, and interests.
        """
        if request.user.role != 'volunteer':
            return Response(
                {"detail": "Рекомендации доступны только для волонтеров"},
                status=status.HTTP_403_FORBIDDEN
            )

        recommended_events = get_recommended_events(request.user, limit=10)
        serializer = self.get_serializer(recommended_events, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'], url_path='similar', permission_classes=[permissions.AllowAny])
    def similar(self, request, pk=None):
        """
        Get events similar to the current event.
        Based on category and organizer.
        """
        event = self.get_object()
        similar_events = get_similar_events(event, limit=5)
        serializer = self.get_serializer(similar_events, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='popular', permission_classes=[permissions.AllowAny])
    def popular(self, request):
        """
        Get most popular events based on registration count.
        """
        popular_events = get_popular_events(limit=10)
        serializer = self.get_serializer(popular_events, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def check_in(self, request, pk=None):
        """
        Check-in to event using geofencing.
        Requires user's current location (lat, lng).
        """
        event = self.get_object()
        user = request.user

        # Get user's location
        user_lat = request.data.get('latitude')
        user_lng = request.data.get('longitude')

        if not user_lat or not user_lng:
            return Response(
                {'detail': 'Требуются координаты (latitude, longitude)'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user_lat = float(user_lat)
            user_lng = float(user_lng)
        except ValueError:
            return Response(
                {'detail': 'Неверный формат координат'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get user's registration
        try:
            registration = EventRegistration.objects.get(event=event, volunteer=user)
        except EventRegistration.DoesNotExist:
            return Response(
                {'detail': 'Вы не зарегистрированы на это мероприятие'},
                status=status.HTTP_404_NOT_FOUND
            )

        # Check auto-attendance
        result = check_auto_attendance(registration, user_lat, user_lng)

        if result['success']:
            return Response(result)
        else:
            return Response(result, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def nearby(self, request):
        """
        Get events near user's current location.
        Requires latitude, longitude, and optional radius_km.
        """
        user_lat = request.data.get('latitude')
        user_lng = request.data.get('longitude')
        radius_km = request.data.get('radius_km', 5)

        if not user_lat or not user_lng:
            return Response(
                {'detail': 'Требуются координаты (latitude, longitude)'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user_lat = float(user_lat)
            user_lng = float(user_lng)
            radius_km = float(radius_km)
        except ValueError:
            return Response(
                {'detail': 'Неверный формат данных'},
                status=status.HTTP_400_BAD_REQUEST
            )

        nearby_events = get_nearby_events(user_lat, user_lng, radius_km)

        # Serialize events with distance info
        results = []
        for item in nearby_events:
            event_data = self.get_serializer(item['event']).data
            event_data['distance_km'] = item['distance_km']
            event_data['distance_m'] = item['distance_m']
            results.append(event_data)

        return Response(results)

    @action(detail=False, methods=['get'], permission_classes=[permissions.AllowAny])
    def calendar(self, request):
        """
        Get events for calendar view by month.
        Query params: year, month
        """
        year = request.query_params.get('year')
        month = request.query_params.get('month')

        if not year or not month:
            return Response(
                {'detail': 'Требуются параметры year и month'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            year = int(year)
            month = int(month)
        except ValueError:
            return Response(
                {'detail': 'Неверный формат year или month'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not (1 <= month <= 12):
            return Response(
                {'detail': 'month должен быть от 1 до 12'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = request.user if request.user.is_authenticated else None
        events_by_day = get_events_by_month(year, month, user)
        summary = get_calendar_summary(year, month, user)

        return Response({
            'events_by_day': events_by_day,
            'summary': summary
        })

    @action(detail=False, methods=['get'], permission_classes=[permissions.AllowAny])
    def week(self, request):
        """
        Get events for week view.
        Query params: year, week
        """
        year = request.query_params.get('year')
        week = request.query_params.get('week')

        if not year or not week:
            return Response(
                {'detail': 'Требуются параметры year и week'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            year = int(year)
            week = int(week)
        except ValueError:
            return Response(
                {'detail': 'Неверный формат year или week'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = request.user if request.user.is_authenticated else None
        events_by_day = get_events_by_week(year, week, user)

        return Response({'events_by_day': events_by_day})

    @action(detail=False, methods=['get'], permission_classes=[permissions.AllowAny])
    def search(self, request):
        """
        Full-text search for events.
        Query params: q (search query), category, status, type, is_urgent
        """
        query = request.query_params.get('q', '')

        filters = {}
        if request.query_params.get('category'):
            filters['category'] = request.query_params.get('category')
        if request.query_params.get('status'):
            filters['status'] = request.query_params.get('status')
        if request.query_params.get('type'):
            filters['type'] = request.query_params.get('type')
        if request.query_params.get('is_urgent'):
            filters['is_urgent'] = request.query_params.get('is_urgent') == 'true'

        events = search_events(query, filters)

        page = self.paginate_queryset(events)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(events, many=True)
        return Response(serializer.data)
