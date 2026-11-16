from django.http import JsonResponse
from django.db import connections
from django.db.utils import OperationalError
from django.core.cache import cache
import logging

logger = logging.getLogger(__name__)

def health_check(request):
    """
    Comprehensive health check endpoint for Kubernetes/monitoring.
    Checks Database and Cache (Redis).
    """
    health = {
        "status": "healthy",
        "components": {
            "database": "up",
            "cache": "up"
        }
    }
    
    # Check Database
    try:
        db_conn = connections['default']
        db_conn.cursor()
    except OperationalError:
        health["status"] = "unhealthy"
        health["components"]["database"] = "down"
        logger.error("Health check failed: Database is down")
    
    # Check Cache (Redis)
    try:
        cache.set('health_check_test', 'ok', timeout=5)
        if cache.get('health_check_test') != 'ok':
            raise Exception("Cache check failed")
    except Exception:
        health["status"] = "unhealthy"
        health["components"]["cache"] = "down"
        logger.error("Health check failed: Cache (Redis) is down")
    
    status_code = 200 if health["status"] == "healthy" else 503
    return JsonResponse(health, status=status_code)
