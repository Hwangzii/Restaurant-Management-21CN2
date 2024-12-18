from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EmployeeViewSet, InvoiceFoodViewSet, LoginView, VerifyOTPView, FloorViewSet, TableViewSet, AccountViewSet, MenuItemViewSet, InventoryViewSet, WorkScheduleViewSet

router = DefaultRouter()
router.register('accounts', AccountViewSet, basename='accounts')
router.register('menu_items', MenuItemViewSet, basename='menu_items')
router.register('floors', FloorViewSet, basename='floors')
router.register('tables', TableViewSet, basename='tables')
router.register('employees', EmployeeViewSet, basename='employees')
router.register('items', InventoryViewSet, basename='inventory')
router.register('invoice_food', InvoiceFoodViewSet, basename='invoice_food')
router.register('work_schedule', WorkScheduleViewSet, basename='work_schedule')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/', LoginView.as_view(), name='login'),
    path('verify_otp/', VerifyOTPView.as_view(), name='verify_otp'),
    path('', include(router.urls)),
]

