from django.urls import path
from .views import LoginView, SignupView, AccountListView, VerifyOTPView

urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
    path('verify_otp/', VerifyOTPView.as_view(), name='verify_otp'),  # Xác thực OTP
    path('signup/', SignupView.as_view(), name='signup'),
    path('accounts/', AccountListView.as_view(), name='account-list'),

]
