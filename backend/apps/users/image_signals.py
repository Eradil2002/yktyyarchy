"""
Image compression signals.
Automatically compress avatar / event images after they are saved to disk.
"""
from django.db.models.signals import post_save
from django.dispatch import receiver

from apps.users.image_utils import compress_image, AVATAR_MAX_DIMENSION, MAX_IMAGE_DIMENSION
from apps.users.models import CustomUser
from apps.events.models import Event


@receiver(post_save, sender=CustomUser)
def compress_user_avatar(sender, instance, created, **kwargs):
    """Compress avatar on every save that includes a new / updated image."""
    if not instance.avatar:
        return

    try:
        compress_image(
            instance.avatar,
            max_dimension=AVATAR_MAX_DIMENSION,
            quality=85,
            output_format="JPEG",
        )
    except Exception:
        # Never block a save due to image processing errors.
        pass


@receiver(post_save, sender=Event)
def compress_event_image(sender, instance, created, **kwargs):
    """Compress event cover image on every save that includes a new image."""
    if not instance.image:
        return

    try:
        compress_image(
            instance.image,
            max_dimension=MAX_IMAGE_DIMENSION,
            quality=85,
            output_format="JPEG",
        )
    except Exception:
        pass
