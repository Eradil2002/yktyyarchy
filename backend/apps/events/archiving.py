"""
Event archiving utilities for moving old completed events to archive status.
"""
from django.utils import timezone
from datetime import timedelta
from apps.events.models import Event


def archive_old_events(days_threshold=90):
    """
    Archive events that have been completed for more than the specified threshold.

    Args:
        days_threshold: Number of days after completion to archive (default: 90)

    Returns:
        Number of events archived
    """
    cutoff_date = timezone.now() - timedelta(days=days_threshold)

    # Find completed events older than threshold that aren't deleted
    old_events = Event.objects.filter(
        status='completed',
        date__lt=cutoff_date,
        deleted_at__isnull=True
    )

    archived_count = 0
    for event in old_events:
        # Soft delete the event to archive it
        event.soft_delete()
        archived_count += 1

    return archived_count


def get_archivable_events(days_threshold=90):
    """
    Get list of events that are eligible for archiving.

    Args:
        days_threshold: Number of days after completion to consider for archiving

    Returns:
        QuerySet of events eligible for archiving
    """
    cutoff_date = timezone.now() - timedelta(days=days_threshold)

    return Event.objects.filter(
        status='completed',
        date__lt=cutoff_date,
        deleted_at__isnull=True
    )


def restore_archived_event(event_id):
    """
    Restore an archived event from soft delete.

    Args:
        event_id: ID of the event to restore

    Returns:
        Restored event or None if not found
    """
    try:
        event = Event.all_objects.get(id=event_id, deleted_at__isnull=False)
        event.deleted_at = None
        event.deleted_by = None
        event.save()
        return event
    except Event.DoesNotExist:
        return None
