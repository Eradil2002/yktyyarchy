import math
from datetime import timedelta
from django.utils import timezone


def haversine_distance(lat1, lon1, lat2, lon2):
    """
    Calculate the great circle distance between two points in meters.

    Args:
        lat1, lon1: First point coordinates
        lat2, lon2: Second point coordinates

    Returns:
        float: Distance in meters
    """
    R = 6371000  # Earth radius in meters

    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = math.sin(delta_phi / 2) ** 2 + \
        math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    return R * c


def is_within_geofence(user_lat, user_lon, event_lat, event_lon, radius_meters=100):
    """
    Check if user is within geofence radius of event location.

    Args:
        user_lat, user_lon: User's current coordinates
        event_lat, event_lon: Event location coordinates
        radius_meters: Geofence radius in meters (default: 100m)

    Returns:
        bool: True if user is within geofence
    """
    if not all([user_lat, user_lon, event_lat, event_lon]):
        return False

    distance = haversine_distance(user_lat, user_lon, event_lat, event_lon)
    return distance <= radius_meters


def check_auto_attendance(registration, user_lat, user_lon):
    """
    Check if volunteer should be automatically marked as attended based on location.

    Args:
        registration: EventRegistration instance
        user_lat, user_lon: User's current coordinates

    Returns:
        dict: Result with status and message
    """
    event = registration.event

    # Check if event has location coordinates
    if not event.latitude or not event.longitude:
        return {
            'success': False,
            'message': 'У события нет координат для геофенсинга'
        }

    # Check if event is happening now (within 2 hours before to 2 hours after)
    now = timezone.now()
    event_start = event.date
    event_end = event.end_time if event.end_time else event.date + timedelta(hours=4)

    time_window_start = event_start - timedelta(hours=2)
    time_window_end = event_end + timedelta(hours=2)

    if not (time_window_start <= now <= time_window_end):
        return {
            'success': False,
            'message': 'Автоматическая отметка доступна только во время события'
        }

    # Check if user is within geofence
    if is_within_geofence(user_lat, user_lon, event.latitude, event.longitude, radius_meters=100):
        # Mark as attended
        if registration.status != 'attended':
            registration.status = 'attended'
            registration.save()

            return {
                'success': True,
                'message': 'Вы автоматически отмечены как присутствующий',
                'distance': haversine_distance(user_lat, user_lon, event.latitude, event.longitude)
            }
        else:
            return {
                'success': True,
                'message': 'Вы уже отмечены как присутствующий',
                'distance': haversine_distance(user_lat, user_lon, event.latitude, event.longitude)
            }
    else:
        distance = haversine_distance(user_lat, user_lon, event.latitude, event.longitude)
        return {
            'success': False,
            'message': f'Вы находитесь слишком далеко от места события ({int(distance)}м)',
            'distance': distance
        }


def get_nearby_events(user_lat, user_lon, radius_km=5):
    """
    Get events near user's location.

    Args:
        user_lat, user_lon: User's current coordinates
        radius_km: Search radius in kilometers

    Returns:
        list: Events with distance information
    """
    from apps.events.models import Event

    # Get all open events with coordinates
    events = Event.objects.filter(
        status='open',
        date__gte=timezone.now(),
        latitude__isnull=False,
        longitude__isnull=False
    )

    nearby_events = []

    for event in events:
        distance = haversine_distance(user_lat, user_lon, event.latitude, event.longitude)
        distance_km = distance / 1000

        if distance_km <= radius_km:
            nearby_events.append({
                'event': event,
                'distance_km': round(distance_km, 2),
                'distance_m': int(distance)
            })

    # Sort by distance
    nearby_events.sort(key=lambda x: x['distance_km'])

    return nearby_events
