from django.contrib import admin
from .models import Event, EventRegistration

@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    list_display = ('title', 'organizer', 'category', 'date', 'status', 'is_urgent')
    list_filter = ('status', 'category', 'is_urgent')
    search_fields = ('title', 'description', 'location')
    date_hierarchy = 'date'

@admin.register(EventRegistration)
class EventRegistrationAdmin(admin.ModelAdmin):
    list_display = ('event', 'volunteer', 'status', 'registered_at')
    list_filter = ('status',)
