from django.apps import AppConfig


class UsersConfig(AppConfig):
    name = 'apps.users'

    def ready(self):
        # Register image compression signals.
        import apps.users.image_signals  # noqa: F401

