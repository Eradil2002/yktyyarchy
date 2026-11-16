from rest_framework import permissions


class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Object-level permission: only the owner (or staff) may modify/delete.
    The view sets `owner_field` (e.g. 'organizer', 'author', 'reviewer').
    """

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        if not request.user or not request.user.is_authenticated:
            return False
        if request.user.is_staff:
            return True
        owner_field = getattr(view, 'owner_field', 'user')
        return getattr(obj, f'{owner_field}_id', None) == request.user.pk
