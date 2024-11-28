from django.urls import path
from .views import LoginView, SignupView, AccountListView

urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
    path('signup/', SignupView.as_view(), name='signup'),
    path('accounts/', AccountListView.as_view(), name='account-list'),
]
