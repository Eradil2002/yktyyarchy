from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, VolunteerProfile, NGOProfile
from .security_log import SecurityLog

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'role', 'is_verified', 'total_hours', 'rating')
    list_filter = ('role', 'is_verified')
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('role', 'phone', 'avatar', 'location', 'total_hours', 'rating', 'is_verified')}),
    )

@admin.register(VolunteerProfile)
class VolunteerProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'bio')

@admin.register(NGOProfile)
class NGOProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'org_name', 'contact_email')

@admin.register(SecurityLog)
class SecurityLogAdmin(admin.ModelAdmin):
    list_display = ['timestamp', 'event_type', 'user', 'username_attempted', 'ip_address']
    list_filter = ['event_type', 'timestamp']
    search_fields = ['user__username', 'username_attempted', 'ip_address']
    readonly_fields = ['timestamp', 'event_type', 'user', 'ip_address', 'user_agent', 'username_attempted', 'details']
    ordering = ['-timestamp']

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

