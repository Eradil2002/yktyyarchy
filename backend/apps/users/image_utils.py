"""
Image compression utilities.
Automatically resize and compress uploaded images using Pillow.
Called from model signals and serializer validators.
"""
from __future__ import annotations

import io
import os
from pathlib import Path

from PIL import Image


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
# Maximum dimension (width or height) for general images.
MAX_IMAGE_DIMENSION = 1920
# Compact avatar / thumbnail size.
AVATAR_MAX_DIMENSION = 512
# JPEG quality (1-95). 85 gives a good visual / file-size balance.
JPEG_QUALITY = 85
# WebP quality.
WEBP_QUALITY = 82
# Supported input formats that we are allowed to convert to JPEG / WebP.
CONVERTIBLE_FORMATS = {"jpeg", "jpg", "png", "bmp", "tiff", "tif", "gif"}


# ---------------------------------------------------------------------------
# Public helpers
# ---------------------------------------------------------------------------

def compress_image(
    image_field,
    *,
    max_dimension: int = MAX_IMAGE_DIMENSION,
    quality: int = JPEG_QUALITY,
    output_format: str = "JPEG",
    convert_to_webp: bool = False,
) -> bool:
    """Compress and resize an ImageField in-place.

    Args:
        image_field: A Django ImageFieldFile (e.g. instance.photo).
        max_dimension: Longest side will be capped at this value.
        quality: Compression quality for JPEG / WebP (1-95).
        output_format: Output PIL format string, e.g. "JPEG" or "WEBP".
        convert_to_webp: If True, converts to WebP and renames the file.

    Returns:
        True if the image was rewritten, False if no action was needed.
    """
    if not image_field or not image_field.name:
        return False

    try:
        image_field.seek(0)
    except Exception:
        pass

    try:
        img = Image.open(image_field)
    except Exception:
        return False

    original_format = (img.format or "JPEG").upper()
    ext = Path(image_field.name).suffix.lower().lstrip(".")

    # Skip if the image is already small enough and not requesting WebP.
    width, height = img.size
    needs_resize = width > max_dimension or height > max_dimension
    needs_convert = convert_to_webp and original_format not in ("WEBP",)

    if not needs_resize and not needs_convert:
        return False

    # ----- Resize -----
    if needs_resize:
        img.thumbnail((max_dimension, max_dimension), Image.LANCZOS)

    # ----- Convert colour mode -----
    if output_format == "JPEG" and img.mode in ("RGBA", "P", "LA"):
        # JPEG does not support transparency; flatten onto white background.
        background = Image.new("RGB", img.size, (255, 255, 255))
        if img.mode == "P":
            img = img.convert("RGBA")
        background.paste(img, mask=img.split()[-1] if img.mode in ("RGBA", "LA") else None)
        img = background
    elif output_format == "JPEG" and img.mode != "RGB":
        img = img.convert("RGB")

    # ----- Save back into the field -----
    fmt = "WEBP" if convert_to_webp else output_format
    buffer = io.BytesIO()
    save_kwargs: dict = {"format": fmt, "optimize": True}
    if fmt in ("JPEG", "WEBP"):
        save_kwargs["quality"] = quality

    img.save(buffer, **save_kwargs)
    buffer.seek(0)

    # Update the file content without changing the storage path.
    image_field.seek(0)
    image_field.write(buffer.read())
    image_field.truncate()
    image_field.seek(0)

    return True


def compress_image_file(
    file_path: str | Path,
    *,
    max_dimension: int = MAX_IMAGE_DIMENSION,
    quality: int = JPEG_QUALITY,
    output_format: str = "JPEG",
) -> int:
    """Compress an image file on disk.

    Returns:
        Size reduction in bytes (original_size - new_size).
        Returns 0 if the file was skipped or an error occurred.
    """
    path = Path(file_path)
    if not path.exists():
        return 0

    ext = path.suffix.lower().lstrip(".")
    if ext not in CONVERTIBLE_FORMATS:
        return 0

    original_size = path.stat().st_size

    try:
        with Image.open(path) as img:
            width, height = img.size
            if width <= max_dimension and height <= max_dimension:
                # Still re-save to strip EXIF / optimise.
                pass

            img.thumbnail((max_dimension, max_dimension), Image.LANCZOS)

            if output_format == "JPEG" and img.mode not in ("RGB",):
                img = img.convert("RGB")

            save_kwargs: dict = {
                "format": output_format,
                "optimize": True,
            }
            if output_format in ("JPEG", "WEBP"):
                save_kwargs["quality"] = quality

            img.save(path, **save_kwargs)
    except Exception:
        return 0

    new_size = path.stat().st_size
    return max(0, original_size - new_size)


def get_image_info(file_path: str | Path) -> dict:
    """Return basic metadata for an image file."""
    path = Path(file_path)
    if not path.exists():
        return {}

    try:
        with Image.open(path) as img:
            return {
                "width": img.width,
                "height": img.height,
                "format": img.format,
                "mode": img.mode,
                "size_bytes": path.stat().st_size,
            }
    except Exception:
        return {}
