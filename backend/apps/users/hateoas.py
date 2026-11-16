"""
HATEOAS (Hypermedia as the Engine of Application State) utilities.
Adds hypermedia links to API responses for better discoverability.
"""
from rest_framework.reverse import reverse


def add_event_links(event, request):
    """
    Add HATEOAS links to event object.

    Args:
        event: Event instance
        request: HTTP request object

    Returns:
        Dictionary with hypermedia links
    """
    links = {
        'self': reverse('event-detail', kwargs={'pk': event.pk}, request=request),
        'register': reverse('event-register', kwargs={'pk': event.pk}, request=request),
        'unregister': reverse('event-unregister', kwargs={'pk': event.pk}, request=request),
        'similar': reverse('event-similar', kwargs={'pk': event.pk}, request=request),
        'statistics': reverse('event-statistics', kwargs={'pk': event.pk}, request=request),
        'check_in': reverse('event-check-in', kwargs={'pk': event.pk}, request=request),
        'organizer': reverse('user_detail', kwargs={'pk': event.organizer.pk}, request=request),
    }

    # Add QR code generation link if user is organizer
    if request.user.is_authenticated and event.organizer == request.user:
        links['generate_qr'] = reverse('event-generate-qr', kwargs={'pk': event.pk}, request=request)

    return links


def add_user_links(user, request):
    """
    Add HATEOAS links to user object.

    Args:
        user: CustomUser instance
        request: HTTP request object

    Returns:
        Dictionary with hypermedia links
    """
    links = {
        'self': reverse('user_detail', kwargs={'pk': user.pk}, request=request),
        # 'events': reverse('customuser-organized-events', kwargs={'pk': user.pk}, request=request),
        # 'initiatives': reverse('customuser-initiatives', kwargs={'pk': user.pk}, request=request),
        # 'reviews': reverse('customuser-reviews', kwargs={'pk': user.pk}, request=request),
    }

    # Add profile-specific links if viewing own profile
    if request.user.is_authenticated and request.user.pk == user.pk:
        # links['my_registrations'] = reverse('event-my-registrations', request=request)
        # links['recommended_events'] = reverse('event-recommended', request=request)
        links['export_pdf'] = reverse('export_volunteer_book', request=request)

    return links


def add_initiative_links(initiative, request):
    """
    Add HATEOAS links to initiative object.

    Args:
        initiative: Initiative instance
        request: HTTP request object

    Returns:
        Dictionary with hypermedia links
    """
    links = {
        'self': reverse('initiative-detail', kwargs={'pk': initiative.pk}, request=request),
        'author': reverse('user_detail', kwargs={'pk': initiative.author.pk}, request=request),
    }

    # Add moderation links if user is staff
    if request.user.is_authenticated and request.user.is_staff:
        links['approve'] = reverse('initiative-approve', kwargs={'pk': initiative.pk}, request=request)
        links['reject'] = reverse('initiative-reject', kwargs={'pk': initiative.pk}, request=request)

    return links


def add_review_links(review, request):
    """
    Add HATEOAS links to review object.

    Args:
        review: Review instance
        request: HTTP request object

    Returns:
        Dictionary with hypermedia links
    """
    links = {
        'self': reverse('review-detail', kwargs={'pk': review.pk}, request=request),
        'reviewer': reverse('user_detail', kwargs={'pk': review.reviewer.pk}, request=request),
        'target_user': reverse('user_detail', kwargs={'pk': review.target_user.pk}, request=request),
    }

    if review.event:
        links['event'] = reverse('event-detail', kwargs={'pk': review.event.pk}, request=request)

    # Add report link
    links['report'] = reverse('report-list', request=request)

    return links


def add_registration_links(registration, request):
    """
    Add HATEOAS links to event registration object.

    Args:
        registration: EventRegistration instance
        request: HTTP request object

    Returns:
        Dictionary with hypermedia links
    """
    links = {
        'event': reverse('event-detail', kwargs={'pk': registration.event.pk}, request=request),
        'volunteer': reverse('user_detail', kwargs={'pk': registration.volunteer.pk}, request=request),
        'unregister': reverse('event-unregister', kwargs={'pk': registration.event.pk}, request=request),
    }

    return links


def add_pagination_links(page, request):
    """
    Add HATEOAS pagination links.

    Args:
        page: Paginated page object
        request: HTTP request object

    Returns:
        Dictionary with pagination links
    """
    links = {}

    if page.has_next():
        links['next'] = page.next_page_number()

    if page.has_previous():
        links['previous'] = page.previous_page_number()

    links['first'] = 1
    links['last'] = page.paginator.num_pages

    return links


def add_collection_links(request, resource_name):
    """
    Add HATEOAS links for collection endpoints.

    Args:
        request: HTTP request object
        resource_name: Name of the resource (e.g., 'event', 'user', 'initiative')

    Returns:
        Dictionary with collection links
    """
    links = {
        'self': request.build_absolute_uri(),
    }

    # Add create link if user is authenticated
    if request.user.is_authenticated:
        if resource_name == 'event' and request.user.role == 'ngo':
            links['create'] = reverse('event-list', request=request)
        elif resource_name == 'initiative':
            links['create'] = reverse('initiative-list', request=request)
        elif resource_name == 'review':
            links['create'] = reverse('review-list', request=request)

    # Add search/filter links
    links['search'] = f"{reverse(f'{resource_name}-list', request=request)}?search="
    links['filter'] = f"{reverse(f'{resource_name}-list', request=request)}?category="

    return links
