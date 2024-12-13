from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import LoginView, MenuItemDetail, MenuItemList, SignupView, AccountListView, VerifyOTPView, FloorViewSet, TableViewSet

router = DefaultRouter()
router.register(r'floors', FloorViewSet, basename='floor')
router.register(r'tables', TableViewSet, basename='table')

urlpatterns = [
    path('', include(router.urls)),
    path('login/', LoginView.as_view(), name='login'),
    path('verify_otp/', VerifyOTPView.as_view(), name='verify_otp'),  # Xác thực OTP
    path('signup/', SignupView.as_view(), name='signup'),
    path('accounts/', AccountListView.as_view(), name='account-list'),
    path('menu_items/', MenuItemList.as_view(), name='menu-item-list'),  # Lấy danh sách & thêm món ăn
    path('menu_items/<int:pk>/', MenuItemDetail.as_view(), name='menu-item-detail'),  # Lấy thông tin, sửa, xóa món ăn
]
