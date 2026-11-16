from django.apps import AppConfig


class EventsConfig(AppConfig):
    name = 'apps.events'
    default_auto_field = 'django.db.models.BigAutoField'

    def ready(self):
        import apps.events.signals  # noqa
