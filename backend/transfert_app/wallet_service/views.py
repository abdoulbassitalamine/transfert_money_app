from django.shortcuts import get_object_or_404
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.conf import settings
from .models import Wallet
from .serializers import WalletSerializer
from django.contrib.auth import get_user_model
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication
from decimal import Decimal

User = get_user_model()

# Classe pour faire un dépôt
class WalletDepositView(APIView):

    permission_classes = [AllowAny]
    
    def post(self, request, *args, **kwargs):
        user_id = request.data.get('user_id')
        amount = request.data.get('amount')
        
        if not user_id or amount is None or Decimal(amount) <= 0:
            return Response({'error': 'Invalid user ID or amount'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
        
        wallet, created = Wallet.objects.get_or_create(user=user)
        wallet.balance += Decimal(amount)
        wallet.save()
        
        return Response({'message': 'Deposit successful', 'new_balance': wallet.balance})

# Classe pour faire un retrait
class WalletWithdrawView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        user_id = request.data.get('user_id')
        amount = request.data.get('amount')
        
        if not user_id or amount is None or Decimal(amount) <= 0:
            return Response({'error': 'Invalid user ID or amount'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
        
        wallet, created = Wallet.objects.get_or_create(user=user)
        if wallet.balance < float(amount):
            return Response({'error': 'Insufficient balance'}, status=status.HTTP_400_BAD_REQUEST)
        
        wallet.balance -= Decimal(amount)
        wallet.save()
        
        return Response({'message': 'Withdrawal successful', 'new_balance': wallet.balance})



class WalletBalanceView(APIView):
    permission_classes = [AllowAny]
    
    def get(self, request, user_id, *args, **kwargs):
        # Chercher l'utilisateur par ID
        user = get_object_or_404(User, id=user_id)
        # Récupérer le portefeuille associé
        wallet = get_object_or_404(Wallet, user=user)
        
        # Retourner le solde du portefeuille
        return Response({'user_id': user_id, 'balance': wallet.balance})