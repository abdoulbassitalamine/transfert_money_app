from django.contrib import admin

from .models import TransfertAppUser


# Register your models here.

@admin.register(TransfertAppUser)
class TransfertAppUserAdmin(admin.ModelAdmin):
    list_display = ["id","role", "username"]

