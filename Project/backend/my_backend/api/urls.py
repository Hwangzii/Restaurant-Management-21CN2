from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CustomerViewSet, EmployeeViewSet, InvoiceFoodViewSet, InvoiceInventoryViewSet, LoginView, OrderDetailsViewSet, SalariesViewSet, VerifyOTPView, FloorViewSet, TableViewSet, AccountViewSet, MenuItemViewSet, InventoryViewSet, WorkScheduleViewSet

router = DefaultRouter()
router.register('accounts', AccountViewSet, basename='accounts')
router.register('menu_items', MenuItemViewSet, basename='menu_items')
router.register('floors', FloorViewSet, basename='floors')
router.register('tables', TableViewSet, basename='tables')
router.register('employees', EmployeeViewSet, basename='employees')
router.register('items', InventoryViewSet, basename='inventory')
router.register('invoice_food', InvoiceFoodViewSet, basename='invoice_food')
router.register('work_schedule', WorkScheduleViewSet, basename='work_schedule')
router.register('customers', CustomerViewSet, basename='customers')
router.register('invoice_inventory', InvoiceInventoryViewSet, basename='invoice_inventory')
router.register('salaries', SalariesViewSet, basename='salaries')
router.register('orders', OrderDetailsViewSet, basename='order-details')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/', LoginView.as_view(), name='login'),
    path('verify_otp/', VerifyOTPView.as_view(), name='verify_otp'),
    path('tables/update-status/<str:table_name>/', TableViewSet.as_view({'patch': 'update_status'})),
    path('tables/update-all-status/', TableViewSet.as_view({'patch': 'update_all_status'})),
    path('', include(router.urls)),
]+ router.urls

