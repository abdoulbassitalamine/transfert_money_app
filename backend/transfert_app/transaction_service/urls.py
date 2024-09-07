from django.urls import path
from .views import CreateTransactionView, ConfirmTransactionView, TransactionHistoryView


urlpatterns = [
    path('create/<uuid:user_id>', CreateTransactionView.as_view(), name='create-transation'),
    path('confirm/<int:transaction_id>', ConfirmTransactionView.as_view(), name='confirm-transaction'),
    path('history/<uuid:user_id>',TransactionHistoryView.as_view(), name='history'),
]