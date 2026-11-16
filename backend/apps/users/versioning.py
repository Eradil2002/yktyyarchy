"""
API versioning utilities and configuration.
"""
from rest_framework.versioning import URLPathVersioning, NamespaceVersioning


class APIVersioning(URLPathVersioning):
    """
    URL path versioning for the API.
    Example: /api/v1/events/, /api/v2/events/
    """
    default_version = 'v1'
    allowed_versions = ['v1', 'v2']
    version_param = 'version'


class CustomNamespaceVersioning(NamespaceVersioning):
    """
    Namespace-based versioning for the API.
    Uses URL namespaces to determine version.
    """
    default_version = 'v1'
    allowed_versions = ['v1', 'v2']
