from django.core.exceptions import ValidationError
from django.utils.translation import gettext as _
from django.core.files.images import get_image_dimensions


def validate_file_size(file, max_size_mb=5):
    """
    Validate file size.

    Args:
        file: Uploaded file object
        max_size_mb: Maximum allowed size in megabytes (default: 5MB)

    Raises:
        ValidationError: If file size exceeds the limit
    """
    max_size_bytes = max_size_mb * 1024 * 1024  # Convert MB to bytes

    if file.size > max_size_bytes:
        raise ValidationError(
            _(f'Размер файла не должен превышать {max_size_mb}MB. Текущий размер: {file.size / (1024 * 1024):.2f}MB')
        )


def validate_image_file(file):
    """
    Validate image file (size and dimensions).

    Args:
        file: Uploaded image file

    Raises:
        ValidationError: If validation fails
    """
    # Check file size (max 5MB for images)
    validate_file_size(file, max_size_mb=5)

    # Check if it's a valid image
    try:
        width, height = get_image_dimensions(file)

        if width is None or height is None:
            raise ValidationError(_('Загруженный файл не является корректным изображением.'))

        # Check maximum dimensions (e.g., 4000x4000 pixels)
        max_dimension = 4000
        if width > max_dimension or height > max_dimension:
            raise ValidationError(
                _(f'Размеры изображения не должны превышать {max_dimension}x{max_dimension} пикселей. '
                  f'Текущие размеры: {width}x{height}')
            )

        # Check minimum dimensions (e.g., 50x50 pixels)
        min_dimension = 50
        if width < min_dimension or height < min_dimension:
            raise ValidationError(
                _(f'Размеры изображения должны быть не менее {min_dimension}x{min_dimension} пикселей. '
                  f'Текущие размеры: {width}x{height}')
            )

    except Exception as e:
        raise ValidationError(_('Не удалось обработать изображение. Загрузите корректный файл JPG/PNG/WebP.'))


def validate_avatar(file):
    """
    Validate avatar image (stricter limits).
    Max size: 2MB
    Max dimensions: 2000x2000
    """
    # Check file size (max 2MB for avatars)
    validate_file_size(file, max_size_mb=2)

    try:
        width, height = get_image_dimensions(file)

        if width is None or height is None:
            raise ValidationError(_('Загруженный файл не является корректным изображением.'))

        # Check maximum dimensions for avatar
        max_dimension = 2000
        if width > max_dimension or height > max_dimension:
            raise ValidationError(
                _(f'Размеры аватара не должны превышать {max_dimension}x{max_dimension} пикселей. '
                  f'Текущие размеры: {width}x{height}')
            )

        # Check minimum dimensions
        min_dimension = 100
        if width < min_dimension or height < min_dimension:
            raise ValidationError(
                _(f'Размеры аватара должны быть не менее {min_dimension}x{min_dimension} пикселей. '
                  f'Текущие размеры: {width}x{height}')
            )

    except Exception as e:
        raise ValidationError(_('Не удалось обработать аватар. Загрузите корректный файл JPG/PNG/WebP.'))


def validate_event_image(file):
    """
    Validate event image.
    Max size: 5MB
    Max dimensions: 4000x4000
    """
    validate_image_file(file)


# Allowed file extensions
ALLOWED_IMAGE_EXTENSIONS = ['jpg', 'jpeg', 'png', 'webp']


def validate_image_extension(file):
    """
    Validate that the file has an allowed image extension.
    """
    import os
    ext = os.path.splitext(file.name)[1][1:].lower()

    if ext not in ALLOWED_IMAGE_EXTENSIONS:
        raise ValidationError(
            _(f'Недопустимый формат файла. Разрешены только: {", ".join(ALLOWED_IMAGE_EXTENSIONS)}')
        )
