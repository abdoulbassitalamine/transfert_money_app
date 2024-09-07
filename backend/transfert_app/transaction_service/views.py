from decimal import Decimal
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated, AllowAny
from .models import Transaction
from wallet_service.models import Wallet
from .serializers import TransactionSerializer
from django.contrib.auth import get_user_model

User = get_user_model()

# Endpoint pour créer une nouvelle transaction
class CreateTransactionView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, user_id):
        data = request.data
        sender = get_object_or_404(User, id=user_id)
        receiver_id = data.get('receiver_id')
        amount = data.get('amount')

        try:
            receiver = User.objects.get(id=receiver_id)
        except User.DoesNotExist:
            return Response({"error": "Receiver not found"}, status=status.HTTP_404_NOT_FOUND)

        # Vérifier le solde du portefeuille du sender
        sender_wallet = Wallet.objects.get(user=sender)
        if sender_wallet.balance < Decimal(amount):
            return Response({"error": "Insufficient balance"}, status=status.HTTP_400_BAD_REQUEST)

        # Créer la transaction
        transaction = Transaction.objects.create(
            sender=sender,
            receiver=receiver,
            amount=amount
        )
        
        # Débiter le portefeuille du sender
        sender_wallet.balance -= Decimal(amount)
        sender_wallet.save()
        
        return Response(TransactionSerializer(transaction).data, status=status.HTTP_201_CREATED)

# Endpoint pour confirmer une transaction
class ConfirmTransactionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request,transaction_id ):
        #transaction_id = request.data.get('transaction_id')

        try:
            transaction = Transaction.objects.get(id=transaction_id)
        except Transaction.DoesNotExist:
            return Response({"error": "Transaction not found"}, status=status.HTTP_404_NOT_FOUND)

        if transaction.status != 'pending':
            return Response({"error": "Transaction already processed"}, status=status.HTTP_400_BAD_REQUEST)

        # Créditer le portefeuille du receiver
        receiver_wallet = Wallet.objects.get(user=transaction.receiver)
        receiver_wallet.balance += transaction.amount
        receiver_wallet.save()

        # Confirmer la transaction
        transaction.status = 'confirmed'
        transaction.save()

        return Response(TransactionSerializer(transaction).data, status=status.HTTP_200_OK)

# Endpoint pour afficher l'historique des transactions d'un utilisateur
class TransactionHistoryView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, user_id):
        user = get_object_or_404(User, id=user_id)
        sent_transactions = Transaction.objects.filter(sender=user)
        received_transactions = Transaction.objects.filter(receiver=user)

        transactions = sent_transactions | received_transactions  # Union des deux QuerySets
        transactions = transactions.order_by('created_at')  # Trier par date de création

        return Response(TransactionSerializer(transactions, many=True).data)
