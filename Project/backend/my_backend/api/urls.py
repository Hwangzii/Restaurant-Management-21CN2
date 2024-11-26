from django.urls import path
from .views import AccountListView

urlpatterns = [
    path('accounts/', AccountListView.as_view(), name='account-list'),
]
