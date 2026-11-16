from django.contrib import admin
from .models import Initiative

@admin.register(Initiative)
class InitiativeAdmin(admin.ModelAdmin):
    list_display = ('title', 'author', 'category', 'status', 'hours_claimed', 'created_at')
    list_filter = ('status', 'category')
    search_fields = ('title', 'description', 'location')
    actions = ['approve_initiatives', 'reject_initiatives']

    def approve_initiatives(self, request, queryset):
        for initiative in queryset.filter(status='pending'):
            initiative.status = 'approved'
            initiative.save()
            # Reward hours
            author = initiative.author
            author.total_hours += initiative.hours_claimed
            author.save()
        self.message_user(request, "Selected initiatives approved and hours awarded.")
    
    approve_initiatives.short_description = "Approve pending initiatives and reward hours"

    def reject_initiatives(self, request, queryset):
        queryset.filter(status='pending').update(status='rejected')
        self.message_user(request, "Selected initiatives rejected.")
    
    reject_initiatives.short_description = "Reject selected pending initiatives"
