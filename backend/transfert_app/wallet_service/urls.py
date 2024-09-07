from django.urls import path
from .views import WalletBalanceView, WalletDepositView, WalletWithdrawView

urlpatterns = [
    path('balance/<uuid:user_id>/', WalletBalanceView.as_view(), name='get_balance'),
    path('deposit/', WalletDepositView.as_view(), name='deposit'),
    path('withdraw/', WalletWithdrawView.as_view(), name='withdraw'),
]