from django.contrib import admin
from .models import Review

@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('reviewer', 'target_user', 'rating', 'event', 'is_from_ngo', 'created_at')
    list_filter = ('rating', 'is_from_ngo')
    search_fields = ('text', 'reviewer__username', 'target_user__username')
