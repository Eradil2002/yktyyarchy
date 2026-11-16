from apps.users.permissions import IsOwnerOrReadOnly
from rest_framework import viewsets, permissions, status, serializers, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Avg
from django.utils import timezone
from django_filters.rest_framework import DjangoFilterBackend
from .models import Review, Report
from .serializers import ReviewSerializer, ReportSerializer
from apps.users.models import CustomUser
from apps.events.models import EventRegistration

class ReviewViewSet(viewsets.ModelViewSet):
    owner_field = 'reviewer'
    serializer_class = ReviewSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['moderation_status', 'rating', 'is_from_ngo', 'target_user', 'reviewer']
    search_fields = ['text']
    ordering_fields = ['created_at', 'rating']
    ordering = ['-created_at']

    def get_queryset(self):
        queryset = Review.objects.select_related(
            'reviewer',
            'target_user',
            'event',
            'moderated_by'
        ).order_by('-created_at')

        # Only show approved reviews to non-admin users
        if not self.request.user.is_staff:
            queryset = queryset.filter(moderation_status='approved')

        target_id = self.request.query_params.get('target', None)
        if target_id is not None:
            return queryset.filter(target_user_id=target_id)
        return queryset

    def perform_create(self, serializer):
        target_user = serializer.validated_data.get('target_user')
        reviewer = self.request.user

        # Check if reviewer and target_user participated in the same event
        reviewer_events = EventRegistration.objects.filter(
            volunteer=reviewer,
            status__in=['approved', 'attended']
        ).select_related('event').values_list('event_id', flat=True)

        target_events = EventRegistration.objects.filter(
            volunteer=target_user,
            status__in=['approved', 'attended']
        ).select_related('event').values_list('event_id', flat=True)

        common_events = set(reviewer_events) & set(target_events)

        if not common_events:
            raise serializers.ValidationError(
                'Вы можете оставить отзыв только участникам мероприятий, в которых вы участвовали вместе.'
            )

        review = serializer.save(reviewer=reviewer, is_from_ngo=(getattr(reviewer, 'role', None) == 'ngo'))

        # Update target user rating (only count approved reviews)
        target = review.target_user
        reviews = Review.objects.filter(target_user=target, moderation_status='approved')
        if reviews.exists():
            avg_rating = reviews.aggregate(Avg('rating'))['rating__avg'] or 0.0
            target.rating = round(avg_rating, 1)
            target.save()

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAdminUser])
    def approve(self, request, pk=None):
        """Approve a review (admin only)"""
        review = self.get_object()
        review.moderation_status = 'approved'
        review.moderated_by = request.user
        review.moderated_at = timezone.now()
        review.save()

        # Recalculate target user rating
        target = review.target_user
        reviews = Review.objects.filter(target_user=target, moderation_status='approved')
        if reviews.exists():
            avg_rating = reviews.aggregate(Avg('rating'))['rating__avg'] or 0.0
            target.rating = round(avg_rating, 1)
            target.save()

        return Response({'status': 'approved'})

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAdminUser])
    def reject(self, request, pk=None):
        """Reject a review (admin only)"""
        review = self.get_object()
        reason = request.data.get('reason', '')

        review.moderation_status = 'rejected'
        review.moderated_by = request.user
        review.moderated_at = timezone.now()
        review.moderation_reason = reason
        review.save()

        # Recalculate target user rating (excluding rejected reviews)
        target = review.target_user
        reviews = Review.objects.filter(target_user=target, moderation_status='approved')
        if reviews.exists():
            avg_rating = reviews.aggregate(Avg('rating'))['rating__avg'] or 0.0
            target.rating = round(avg_rating, 1)
        else:
            target.rating = 0.0
        target.save()

        return Response({'status': 'rejected', 'reason': reason})


class ReportViewSet(viewsets.ModelViewSet):
    """
    ViewSet for handling reports of inappropriate content.
    Users can report events, reviews, users, etc.
    """
    serializer_class = ReportSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'report_type', 'content_type']
    search_fields = ['description', 'admin_notes']
    ordering_fields = ['created_at', 'reviewed_at']
    ordering = ['-created_at']

    def get_queryset(self):
        queryset = Report.objects.select_related('reporter', 'reviewed_by', 'content_type')

        # Admin can see all reports, users can only see their own
        if self.request.user.is_staff:
            return queryset
        return queryset.filter(reporter=self.request.user)

    def perform_create(self, serializer):
        serializer.save(reporter=self.request.user)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAdminUser])
    def review(self, request, pk=None):
        """Mark report as reviewed (admin only)"""
        report = self.get_object()
        admin_notes = request.data.get('admin_notes', '')

        report.status = 'reviewed'
        report.reviewed_by = request.user
        report.reviewed_at = timezone.now()
        report.admin_notes = admin_notes
        report.save()

        return Response({'status': 'reviewed'})

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAdminUser])
    def resolve(self, request, pk=None):
        """Mark report as resolved (admin only)"""
        report = self.get_object()
        admin_notes = request.data.get('admin_notes', '')

        report.status = 'resolved'
        report.reviewed_by = request.user
        report.reviewed_at = timezone.now()
        report.admin_notes = admin_notes
        report.save()

        return Response({'status': 'resolved'})

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAdminUser])
    def dismiss(self, request, pk=None):
        """Dismiss report (admin only)"""
        report = self.get_object()
        admin_notes = request.data.get('admin_notes', '')

        report.status = 'dismissed'
        report.reviewed_by = request.user
        report.reviewed_at = timezone.now()
        report.admin_notes = admin_notes
        report.save()

        return Response({'status': 'dismissed'})
