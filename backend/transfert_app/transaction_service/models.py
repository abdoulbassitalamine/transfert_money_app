from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class Transaction(models.Model):
    STATUS_CHOICES = [
        ("pending", "Pending"),
        ("confirmed", "Confirmed"),
        ("Failed", "failed"),
    ]
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    sender = models.ForeignKey(
        User, related_name="sent_transactions", on_delete=models.CASCADE
    )
    receiver = models.ForeignKey(
        User, related_name="received_transactions", on_delete=models.CASCADE
    )
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default="pending")
    created_at = models.DateTimeField(auto_now_add=True)
