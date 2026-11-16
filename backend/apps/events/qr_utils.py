import qrcode
from io import BytesIO
from django.core.files.base import ContentFile
import uuid


def generate_qr_code(data, size=10):
    """
    Generate QR code image.

    Args:
        data: String data to encode in QR code
        size: Size of the QR code (default: 10)

    Returns:
        ContentFile: QR code image as ContentFile
    """
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=size,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")

    # Save to BytesIO
    buffer = BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)

    return ContentFile(buffer.read(), name=f'qr_{uuid.uuid4().hex}.png')


def generate_event_qr_code(event):
    """
    Generate QR code for event registration.

    Args:
        event: Event instance

    Returns:
        ContentFile: QR code image
    """
    # Create registration URL or unique code
    registration_data = f"event:{event.id}:{event.title}"

    return generate_qr_code(registration_data)


def generate_registration_token(event, volunteer):
    """
    Generate unique registration token for QR code scanning.

    Args:
        event: Event instance
        volunteer: User instance

    Returns:
        str: Unique token
    """
    import hashlib
    import time

    # Create unique token based on event, volunteer, and timestamp
    data = f"{event.id}:{volunteer.id}:{time.time()}"
    token = hashlib.sha256(data.encode()).hexdigest()

    return token
