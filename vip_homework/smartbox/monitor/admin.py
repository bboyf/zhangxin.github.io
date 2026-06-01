from django.contrib import admin
from .models import Camera

class CameraAdmin(admin.ModelAdmin):
    list_display = ('name','rtsp','position','is_active','create_time')
    list_per_page = 15

admin.site.register(Camera,CameraAdmin)
