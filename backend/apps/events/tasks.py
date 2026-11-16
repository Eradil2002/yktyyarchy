"""
Celery tasks for event management.
"""
from celery import shared_task
from apps.events.archiving import archive_old_events


@shared_task
def archive_old_events_task(days_threshold=90):
    """
    Celery task to archive old completed events.
    Runs weekly to move events older than threshold to archive.

    Args:
        days_threshold: Number of days after completion to archive (default: 90)

    Returns:
        Number of events archived
    """
    archived_count = archive_old_events(days_threshold)
    return f"Archived {archived_count} old events"
