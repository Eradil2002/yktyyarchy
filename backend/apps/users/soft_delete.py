from django.db import models
from django.utils import timezone


class SoftDeleteManager(models.Manager):
    """
    Manager that excludes soft-deleted objects by default.
    """
    def get_queryset(self):
        return super().get_queryset().filter(deleted_at__isnull=True)


class SoftDeleteModel(models.Model):
    """
    Abstract base model with soft delete functionality.
    """
    deleted_at = models.DateTimeField(null=True, blank=True, db_index=True)
    deleted_by = models.ForeignKey(
        'users.CustomUser',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='%(class)s_deleted'
    )

    objects = SoftDeleteManager()
    all_objects = models.Manager()  # Manager that includes deleted objects

    class Meta:
        abstract = True

    def soft_delete(self, user=None):
        """
        Soft delete the object.
        """
        self.deleted_at = timezone.now()
        self.deleted_by = user
        self.save()

    def restore(self):
        """
        Restore a soft-deleted object.
        """
        self.deleted_at = None
        self.deleted_by = None
        self.save()

    def is_deleted(self):
        """
        Check if object is soft-deleted.
        """
        return self.deleted_at is not None

    def hard_delete(self):
        """
        Permanently delete the object.
        """
        super().delete()
