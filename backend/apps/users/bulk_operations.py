"""
Bulk operations for API endpoints.
Allows creating, updating, and deleting multiple records in a single request.
"""
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db import transaction


class BulkOperationsMixin:
    """
    Mixin to add bulk operations to ViewSets.

    Provides:
    - bulk_create: Create multiple records
    - bulk_update: Update multiple records
    - bulk_delete: Delete multiple records
    """

    @action(detail=False, methods=['post'], url_path='bulk-create')
    def bulk_create(self, request):
        """
        Create multiple records in a single request.

        Request body:
        {
            "items": [
                {field1: value1, field2: value2},
                {field1: value1, field2: value2},
                ...
            ]
        }
        """
        items = request.data.get('items', [])

        if not items:
            return Response(
                {'detail': 'No items provided'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if len(items) > 100:
            return Response(
                {'detail': 'Maximum 100 items allowed per request'},
                status=status.HTTP_400_BAD_REQUEST
            )

        created_items = []
        errors = []

        with transaction.atomic():
            for idx, item_data in enumerate(items):
                serializer = self.get_serializer(data=item_data)

                if serializer.is_valid():
                    self.perform_create(serializer)
                    created_items.append(serializer.data)
                else:
                    errors.append({
                        'index': idx,
                        'errors': serializer.errors
                    })

            # Rollback if any errors
            if errors:
                transaction.set_rollback(True)
                return Response(
                    {
                        'detail': 'Bulk create failed',
                        'errors': errors
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )

        return Response(
            {
                'detail': f'Successfully created {len(created_items)} items',
                'created': created_items
            },
            status=status.HTTP_201_CREATED
        )

    @action(detail=False, methods=['patch'], url_path='bulk-update')
    def bulk_update(self, request):
        """
        Update multiple records in a single request.

        Request body:
        {
            "items": [
                {id: 1, field1: new_value1},
                {id: 2, field2: new_value2},
                ...
            ]
        }
        """
        items = request.data.get('items', [])

        if not items:
            return Response(
                {'detail': 'No items provided'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if len(items) > 100:
            return Response(
                {'detail': 'Maximum 100 items allowed per request'},
                status=status.HTTP_400_BAD_REQUEST
            )

        updated_items = []
        errors = []

        with transaction.atomic():
            for idx, item_data in enumerate(items):
                item_id = item_data.get('id')

                if not item_id:
                    errors.append({
                        'index': idx,
                        'errors': {'id': 'This field is required'}
                    })
                    continue

                try:
                    instance = self.get_queryset().get(pk=item_id)
                except self.queryset.model.DoesNotExist:
                    errors.append({
                        'index': idx,
                        'id': item_id,
                        'errors': {'detail': 'Not found'}
                    })
                    continue

                serializer = self.get_serializer(
                    instance,
                    data=item_data,
                    partial=True
                )

                if serializer.is_valid():
                    self.perform_update(serializer)
                    updated_items.append(serializer.data)
                else:
                    errors.append({
                        'index': idx,
                        'id': item_id,
                        'errors': serializer.errors
                    })

            # Rollback if any errors
            if errors:
                transaction.set_rollback(True)
                return Response(
                    {
                        'detail': 'Bulk update failed',
                        'errors': errors
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )

        return Response(
            {
                'detail': f'Successfully updated {len(updated_items)} items',
                'updated': updated_items
            },
            status=status.HTTP_200_OK
        )

    @action(detail=False, methods=['post'], url_path='bulk-delete')
    def bulk_delete(self, request):
        """
        Delete multiple records in a single request.

        Request body:
        {
            "ids": [1, 2, 3, 4, 5]
        }
        """
        ids = request.data.get('ids', [])

        if not ids:
            return Response(
                {'detail': 'No IDs provided'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if len(ids) > 100:
            return Response(
                {'detail': 'Maximum 100 items allowed per request'},
                status=status.HTTP_400_BAD_REQUEST
            )

        with transaction.atomic():
            queryset = self.get_queryset().filter(pk__in=ids)
            count = queryset.count()

            if count == 0:
                return Response(
                    {'detail': 'No items found with provided IDs'},
                    status=status.HTTP_404_NOT_FOUND
                )

            # Perform delete
            queryset.delete()

        return Response(
            {
                'detail': f'Successfully deleted {count} items',
                'deleted_count': count
            },
            status=status.HTTP_200_OK
        )


class BulkCreateMixin:
    """
    Simplified mixin for bulk create only.
    """

    @action(detail=False, methods=['post'], url_path='bulk-create')
    def bulk_create(self, request):
        """Create multiple records."""
        items = request.data.get('items', [])

        if not items or len(items) > 100:
            return Response(
                {'detail': 'Provide 1-100 items'},
                status=status.HTTP_400_BAD_REQUEST
            )

        serializer = self.get_serializer(data=items, many=True)
        serializer.is_valid(raise_exception=True)

        with transaction.atomic():
            self.perform_create(serializer)

        return Response(
            {
                'detail': f'Created {len(serializer.data)} items',
                'created': serializer.data
            },
            status=status.HTTP_201_CREATED
        )


class BulkUpdateMixin:
    """
    Simplified mixin for bulk update only.
    """

    @action(detail=False, methods=['patch'], url_path='bulk-update')
    def bulk_update(self, request):
        """Update multiple records."""
        items = request.data.get('items', [])

        if not items or len(items) > 100:
            return Response(
                {'detail': 'Provide 1-100 items'},
                status=status.HTTP_400_BAD_REQUEST
            )

        updated = []

        with transaction.atomic():
            for item_data in items:
                item_id = item_data.get('id')
                if not item_id:
                    continue

                try:
                    instance = self.get_queryset().get(pk=item_id)
                    serializer = self.get_serializer(
                        instance,
                        data=item_data,
                        partial=True
                    )
                    serializer.is_valid(raise_exception=True)
                    self.perform_update(serializer)
                    updated.append(serializer.data)
                except self.queryset.model.DoesNotExist:
                    continue

        return Response(
            {
                'detail': f'Updated {len(updated)} items',
                'updated': updated
            },
            status=status.HTTP_200_OK
        )


class BulkDeleteMixin:
    """
    Simplified mixin for bulk delete only.
    """

    @action(detail=False, methods=['post'], url_path='bulk-delete')
    def bulk_delete(self, request):
        """Delete multiple records."""
        ids = request.data.get('ids', [])

        if not ids or len(ids) > 100:
            return Response(
                {'detail': 'Provide 1-100 IDs'},
                status=status.HTTP_400_BAD_REQUEST
            )

        with transaction.atomic():
            count = self.get_queryset().filter(pk__in=ids).delete()[0]

        return Response(
            {
                'detail': f'Deleted {count} items',
                'deleted_count': count
            },
            status=status.HTTP_200_OK
        )
