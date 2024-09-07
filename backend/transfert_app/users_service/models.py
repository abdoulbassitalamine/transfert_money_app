from django.db import models
from django.contrib.auth.models import  AbstractUser, AbstractBaseUser
import uuid


# Create your models here.

class TransfertAppUser(AbstractUser):
    ROLE_SENDER = 'sender'
    ROLE_RECIPIENT = 'recipient'
    ROLE_AGENT = 'agent'
    
    ROLE_CHOICES = [
        (ROLE_SENDER, 'Sender'),
        (ROLE_RECIPIENT, 'Recipient'),
        (ROLE_AGENT, 'Agent'),
    ]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone = models.CharField(unique=True, max_length=9)
    role = models.CharField(max_length=255, choices=(ROLE_CHOICES))
    
    
    
    