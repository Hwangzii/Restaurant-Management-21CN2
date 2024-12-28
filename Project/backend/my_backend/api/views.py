import datetime
from django.shortcuts import get_object_or_404
from rest_framework.decorators import action
import pyotp
from django.utils.timezone import now
from rest_framework import viewsets, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Account, Customer, Employee, Floors, Inventory, Invoice, InvoiceFood, InvoiceInventory, InvoiceSalaries, MenuItem, OrderDetails, Salaries, Tables, WorkSchedule
from .serializers import AccountSerializer, CustomerSerializer, EmployeeSerializer, FloorSerializer, InventorySerializer, InvoiceFooodSerializer, InvoiceInventorySerializer, InvoiceSalariesSerializer, MenuItemSerializer, OrderDetailsSerializer, SalariesSerializer, TableSerializer, WorkScheduleSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.viewsets import ReadOnlyModelViewSet, ModelViewSet
from django.db.models import Exists, OuterRef, Count, Q
from datetime import datetime
from django.db.models.signals import post_save
from django.dispatch import receiver



# Tạo token cho người dùng (JWT)
def get_tokens_for_user(account):
    refresh = RefreshToken.for_user(account)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

# Tạo OTP từ mã bí mật
def generate_otp(secret_key):
    totp = pyotp.TOTP(secret_key)
    return totp.now()  # Tạo OTP hiện tại

# Xác minh OTP
def verify_otp(secret_key, otp, window=1):
    """Xác minh OTP với một cửa sổ hợp lệ."""
    totp = pyotp.TOTP(secret_key)
    return totp.verify(otp, valid_window=window)

# View để đăng nhập và tạo mã QR
class LoginView(APIView):
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        try:
            # Kiểm tra thông tin đăng nhập (kiểm tra username và mật khẩu)
            account = Account.objects.get(username=username)
            # Kiểm tra mật khẩu người dùng
            if password != account.password:
                return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)

            # Nếu người dùng chưa kích hoạt 2FA (chưa có mã bí mật)
            if not account.is_2fa_enabled:
                # Tạo mã bí mật và lưu vào cơ sở dữ liệu nếu chưa có
                if not account.key:
                    account.key = pyotp.random_base32()  # Tạo mã bí mật mới
                    account.save()

                # Tạo mã QR cho Google Authenticator
                totp = pyotp.TOTP(account.key)
                qr_code_url = totp.provisioning_uri(username, issuer_name="YourAppName")  # URL mã QR

                return Response({
                    'message': 'Login successful, scan the QR code to set up 2FA',
                    'qr_code_url': qr_code_url  # Trả mã QR để người dùng quét
                }, status=status.HTTP_200_OK)
            
            else:
                # Nếu người dùng đã kích hoạt 2FA, yêu cầu nhập OTP
                return Response({
                    'message': '2FA already enabled, please enter OTP to login'
                }, status=status.HTTP_200_OK)

        except Account.DoesNotExist:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)

class VerifyOTPView(APIView):
    def post(self, request):
        username = request.data.get('username')
        otp = request.data.get('otp')

        try:
            # Lấy tài khoản
            account = Account.objects.get(username=username)

            # Xác minh OTP
            if verify_otp(account.key, otp, window=1):
                return Response({
                    'message': 'OTP verified successfully',
                    'restaurant_id': account.restaurant_id,
                    'role': account.role,
                    'password': account.password,
                    'name': account.name
                }, status=status.HTTP_200_OK)
            else:
                return Response({'error': 'Invalid OTP'}, status=status.HTTP_400_BAD_REQUEST)

        except Account.DoesNotExist:
            return Response({'error': 'Account not found'}, status=status.HTTP_404_NOT_FOUND)

# View để quản lý tài khoản người dùng
class AccountViewSet(viewsets.ModelViewSet):
    queryset = Account.objects.all()
    serializer_class = AccountSerializer
    # permission_classes = [IsAuthenticated]

# Quản lý MenuItem bằng ModelViewSet để hỗ trợ CRUD đầy đủ
class MenuItemViewSet(ModelViewSet):
    queryset = MenuItem.objects.all()
    serializer_class = MenuItemSerializer
    # permission_classes = [IsAuthenticated]
    
# ViewSet cho Floors
class FloorViewSet(viewsets.ModelViewSet):
    queryset = Floors.objects.all()
    serializer_class = FloorSerializer
    # permission_classes = [IsAuthenticated]

# ViewSet cho Tables
class TableViewSet(viewsets.ModelViewSet):
    queryset = Tables.objects.all()
    serializer_class = TableSerializer
    # permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['patch'], url_path='update-status/(?P<table_name>[^/.]+)')
    def update_status(self, request, table_name=None):
        try:
            # Kiểm tra xem bàn tồn tại không
            table = get_object_or_404(Tables, table_name=table_name)

            # Kiểm tra trạng thái (bàn có món ăn hay không)
            has_orders = OrderDetails.objects.filter(table_name=table_name, status="Pending").exists()

            # Cập nhật status (1 nếu có món, 0 nếu không)
            table.status = has_orders
            table.save()

            return Response({"message": f"Table '{table_name}' status updated to {table.status}."}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
    @action(detail=False, methods=['patch'], url_path='update-all-status')
    def update_all_status(self, request):
        try:
            # Lấy danh sách bàn có món ăn Pending
            tables_with_orders = Tables.objects.annotate(
                has_orders=Exists(
                    OrderDetails.objects.filter(
                        table_name=OuterRef('table_name'),
                        status="Pending"
                    )
                )
            )

            # Cập nhật trạng thái bàn
            updated_tables = []
            for table in tables_with_orders:
                if table.status != table.has_orders:  # Chỉ cập nhật khi có thay đổi
                    table.status = table.has_orders
                    table.save()
                    updated_tables.append(table.table_name)

            return Response(
                {"message": f"Updated tables: {updated_tables}"},
                status=status.HTTP_200_OK,
            )
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class EmployeeViewSet(viewsets.ModelViewSet):
    queryset = Employee.objects.all()
    serializer_class = EmployeeSerializer

class InventoryViewSet(viewsets.ModelViewSet):
    queryset = Inventory.objects.all()
    serializer_class = InventorySerializer

class InvoiceFoodViewSet(viewsets.ModelViewSet):
    queryset = InvoiceFood.objects.all()
    serializer_class = InvoiceFooodSerializer

class WorkScheduleViewSet(viewsets.ModelViewSet):
    queryset = WorkSchedule.objects.all()
    serializer_class = WorkScheduleSerializer

# Cập nhật trạng thái bằng employee_id và shift_type
    @action(detail=False, methods=['post'], url_path='update-status-by-employee', url_name='update_status_by_employee')
    def update_status_by_employee(self, request):
        try:
            # Lấy thông tin từ request
            employee_id = request.data.get('employee_id', None)
            shift_type = request.data.get('shift_type', None)
            new_status = request.data.get('status', None)

            # Kiểm tra các trường bắt buộc
            if not employee_id or not shift_type or not new_status:
                return Response({"error": "Fields 'employee_id', 'shift_type', and 'status' are required."},
                                status=status.HTTP_400_BAD_REQUEST)

            # Tìm WorkSchedule phù hợp
            schedule = WorkSchedule.objects.filter(employee_id=employee_id, shift_type=shift_type).first()

            if not schedule:
                return Response({"error": "WorkSchedule not found for the given employee_id and shift_type."},
                                status=status.HTTP_404_NOT_FOUND)

            # Cập nhật trạng thái
            schedule.status = new_status
            schedule.save()

            return Response({"message": "Status updated successfully."}, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        # Cập nhật lý do nghỉ bằng employee_id và shift_type
    @action(detail=False, methods=['post'], url_path='update-reason-by-employee', url_name='update_reason_by_employee')
    def update_reason_by_employee(self, request):
        try:
            # Lấy thông tin từ request
            employee_id = request.data.get('employee_id', None)
            shift_type = request.data.get('shift_type', None)
            reason = request.data.get('reason', None)

            # Kiểm tra các trường bắt buộc
            if not employee_id or not shift_type or not reason:
                return Response(
                    {"error": "Fields 'employee_id', 'shift_type', and 'reason' are required."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Tìm WorkSchedule phù hợp
            schedule = WorkSchedule.objects.filter(employee_id=employee_id, shift_type=shift_type).first()

            if not schedule:
                return Response(
                    {"error": "WorkSchedule not found for the given employee_id and shift_type."},
                    status=status.HTTP_404_NOT_FOUND
                )

            # Cập nhật lý do nghỉ
            schedule.describe = reason
            schedule.save()

            return Response({"message": "Reason updated successfully."}, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
    # @receiver(post_save, sender=WorkSchedule)
    # def calculate_salary(sender, instance, **kwargs):
    #     try:
    #         # Lấy tháng hiện tại từ bản ghi mới
    #         work_date = instance.work_date
    #         start_date = datetime(work_date.year, work_date.month, 1)
    #         if work_date.month < 12:
    #             end_date = datetime(work_date.year, work_date.month + 1, 1)
    #         else:
    #             end_date = datetime(work_date.year + 1, 1, 1)

    #         # Lấy danh sách nhân viên và thống kê số ca làm việc trong tháng
    #         employees = WorkSchedule.objects.filter(
    #             work_date__gte=start_date, work_date__lt=end_date
    #         ).values('employee_id').annotate(
    #             total_present=Count('status', filter=Q(status="có")),
    #             total_late=Count('status', filter=Q(status="muộn")),
    #             total_absent=Count('status', filter=Q(status="nghỉ không phép"))
    #         )

    #         # Tính lương cho từng nhân viên
    #         for employee in employees:
    #             employee_id = employee['employee_id']
    #             total_present = employee['total_present']
    #             total_late = employee['total_late']
    #             total_absent = employee['total_absent']

    #             # Công thức tính lương
    #             base_salary = 1000000  # Lương cơ bản
    #             bonus = total_present * 50000  # Thưởng mỗi ca có mặt
    #             penalty = total_late * 20000  # Phạt mỗi ca muộn
    #             deduction = total_absent * 100000  # Trừ mỗi ca vắng không phép
    #             total_salary = base_salary + bonus - penalty - deduction

    #             # Lưu hoặc cập nhật lương trong bảng `salaries`
    #             Salaries.objects.update_or_create(
    #                 employees_id=employee_id,
    #                 month=start_date,
    #                 defaults={
    #                     'salary': total_salary,
    #                     'bonus': bonus,
    #                     'penalty': penalty,
    #                     'deduction': deduction,
    #                     'payment_date': now(),
    #                 }
    #             )
    #     except Exception as e:
    #         print(f"Error calculating salary: {e}")


class CustomerViewSet(viewsets.ModelViewSet):
    queryset = Customer.objects.all()
    serializer_class = CustomerSerializer

class InvoiceInventoryViewSet(viewsets.ModelViewSet):
    queryset = InvoiceInventory.objects.all()
    serializer_class = InvoiceInventorySerializer

class SalariesViewSet(viewsets.ModelViewSet):
    queryset = Salaries.objects.all()
    serializer_class = SalariesSerializer

    @action(detail=False, methods=['post'], url_path='create-all-invoices')
    def create_all_invoices(self, request):
        try:
            # Lấy tất cả bản ghi lương chưa thanh toán
            salaries = Salaries.objects.filter(is_paid=False)

            if not salaries.exists():
                return Response({"error": "Không có bản ghi lương nào để thanh toán"}, status=status.HTTP_404_NOT_FOUND)

            invoices = []
            for salary in salaries:
                # Tạo hóa đơn cho từng bản ghi lương
                invoice = InvoiceSalaries.objects.create(
                    employee_name=salary.employee_name,
                    salaries=salary.final_salary,
                    created_at=salary.payment_date,
                    payment_method=request.data.get('payment_method', 'Tiền mặt'),  # Giá trị mặc định
                    salary=salary
                )

                # Đánh dấu bản ghi lương đã thanh toán
                salary.is_paid = True
                salary.save()

                invoices.append(invoice)

            # Trả về danh sách hóa đơn đã tạo
            serializer = InvoiceSalariesSerializer(invoices, many=True)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class InvoiceSalariesViewSet(viewsets.ModelViewSet):
    queryset = InvoiceSalaries.objects.all()
    serializer_class = InvoiceSalariesSerializer

class InvoiceViewSet(viewsets.ModelViewSet):
    queryset = Invoice.objects.all()
    serializer_class = SalariesSerializer
    
class OrderDetailsViewSet(viewsets.ViewSet):
    # Lấy danh sách món theo bàn
    def list(self, request):
        table_name = request.query_params.get('table_name', None)
        if not table_name:
            return Response({"error": "table_name is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        orders = OrderDetails.objects.filter(table_name=table_name)
        serializer = OrderDetailsSerializer(orders, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='list-chef')
    def list_chef(self, request):
        try:
            orders = OrderDetails.objects.filter(status="Pending")  # Lấy tất cả món ăn đang 'Pending'
            serializer = OrderDetailsSerializer(orders, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    # Cập nhật trạng thái món thành "Served"
    @action(detail=True, methods=['patch'], url_path='mark-as-served')
    def mark_as_served(self, request, pk=None):
        try:
            # Tìm món ăn theo ID
            order = OrderDetails.objects.get(pk=pk)
            
            # Kiểm tra trạng thái hiện tại
            if order.status == "Served":
                return Response(
                    {"message": "Order is already served."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            
            # Cập nhật trạng thái thành "Served"
            order.status = "Served"
            order.save()

            return Response(
                {"message": "Order marked as served successfully."},
                status=status.HTTP_200_OK,
            )
        except OrderDetails.DoesNotExist:
            return Response(
                {"error": "Order not found."},
                status=status.HTTP_404_NOT_FOUND,
            )
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

    # Thêm món mới
    def create(self, request):
        # Kiểm tra dữ liệu đầu vào
        table_name = request.data.get('table_name')
        item_name = request.data.get('item_name')
        quantity = request.data.get('quantity')
        item_price = request.data.get('item_price')

        if not table_name or not item_name or quantity is None or item_price is None:
            return Response({"error": "All fields are required (table_name, item_name, quantity, item_price)"}, status=status.HTTP_400_BAD_REQUEST)

        # Tạo serializer và lưu món ăn mới
        serializer = OrderDetailsSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # Xóa một đơn hàng theo ID
    def destroy(self, request, pk=None):
        try:
            order = OrderDetails.objects.get(pk=pk)
            order.delete()
            return Response({"message": f"Order {pk} deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
        except OrderDetails.DoesNotExist:
            return Response({"error": "Order not found."}, status=status.HTTP_404_NOT_FOUND)

    # Kiểm tra xem bàn có món không
    @action(detail=False, methods=['get'], url_path='getcheck')
    def getcheck(self, request):
        table_name = request.query_params.get('table_name', None)
        if not table_name:
            return Response({"error": "table_name is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            has_orders = OrderDetails.objects.filter(table_name=table_name, status="Pending").exists()
            return Response({"has_orders": has_orders}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        
    # Xóa tất cả món của một bàn
    @action(detail=False, methods=['delete'], url_path='clear')
    def clear(self, request):
        table_name = request.query_params.get('table_name', None)
        if not table_name:
            return Response({"error": "table_name is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        OrderDetails.objects.filter(table_name=table_name).delete()
        return Response({"message": f"Orders cleared for table {table_name}"}, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'], url_path='has-buffet')
    def has_buffet(self, request):
        table_name = request.query_params.get('table_name', None)
        if not table_name:
            return Response({"error": "table_name is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Tìm item_name chứa 'buffet' liên quan đến table_name
        buffet_items = OrderDetails.objects.filter(table_name=table_name, item_name__icontains="Buffet")
        
        if buffet_items.exists():
            # Lấy tên Buffet từ bản ghi đầu tiên tìm thấy
            buffet_name = buffet_items.first().item_name
            return Response({"has_buffet": True, "buffet_name": buffet_name}, status=status.HTTP_200_OK)
        
        return Response({"has_buffet": False}, status=status.HTTP_200_OK)

    @action(detail=False, methods=['patch'], url_path='upgrade-buffet')
    def upgrade_buffet(self, request):
        table_name = request.data.get('table_name', None)
        
        if not table_name:
            return Response({"error": "table_name is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Lọc các món "Buffet đỏ"
            buffet_orders = OrderDetails.objects.filter(table_name=table_name, item_name__icontains="buffet đỏ")
            
            # Kiểm tra nếu không có món "Buffet đỏ"
            if not buffet_orders.exists():
                return Response(
                    {"message": f"No 'Buffet đỏ' found for table '{table_name}'. Upgrade not possible."},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Cập nhật từng món
            updated_items = []
            for order in buffet_orders:
                order.item_name = "Buffet đen"
                order.item_price = order.item_price + 50000
                order.save()
                updated_items.append(order.id)

            return Response({
                "message": "Buffet orders upgraded successfully.",
                "updated_items": updated_items
            }, status=status.HTTP_200_OK)
        
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
    @action(detail=False, methods=['patch'], url_path='transfer')
    def transfer_orders(self, request):
        old_table_name = request.data.get('old_table_name')
        new_table_name = request.data.get('new_table_name')

        if not old_table_name or not new_table_name:
            return Response({"error": "Both old_table_name and new_table_name are required"},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            # Kiểm tra trạng thái bàn mới
            new_table = get_object_or_404(Tables, table_name=new_table_name)
            if new_table.status:
                return Response({"error": "New table is not available"},
                                status=status.HTTP_400_BAD_REQUEST)

            # Cập nhật tất cả các món sang bàn mới
            OrderDetails.objects.filter(table_name=old_table_name).update(table_name=new_table_name)

            # Cập nhật trạng thái bàn
            old_table = get_object_or_404(Tables, table_name=old_table_name)
            old_table.status = False
            old_table.save()

            new_table.status = True
            new_table.save()

            return Response({"message": "Orders transferred successfully"},
                            status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['post'], url_path='add-multiple-items')
    def add_multiple_items(self, request):
        items = request.data.get('items', [])
        table_name = request.data.get('table_name', '')
        buffet = request.data.get('buffet', None)

        if not items or not table_name:
            return Response(
                {'error': 'Invalid data. Items and table_name are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            # Thêm Buffet nếu có
            if buffet:
                OrderDetails.objects.create(
                    table_name=table_name,
                    item_name=buffet['item_name'],
                    quantity=buffet['quantity'],
                    item_price=buffet['item_price'],
                    status='Pending',
                )

            # Thêm từng món ăn từ danh sách items
            for item in items:
                OrderDetails.objects.create(
                    table_name=table_name,
                    item_name=item['item_name'],
                    quantity=item['quantity'],
                    item_price=item['item_price'],
                    type=item.get('type', ''),
                    describe=item.get('describe', ''),
                    status=item['status'],
                )

            return Response({'message': 'Items added successfully.'}, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)




    # # Tính tổng tiền của một bàn
    # @action(detail=False, methods=['get'], url_path='total')
    # def total(self, request):
    #     table_name = request.query_params.get('table_name', None)
    #     if not table_name:
    #         return Response({"error": "table_name is required"}, status=status.HTTP_400_BAD_REQUEST)
        
    #     total_amount = OrderDetails.objects.filter(table_name=table_name).aggregate(
    #         total=models.Sum(models.F('quantity') * models.F('item_price'))
    #     )['total'] or 0
        
    #     return Response({"table_name": table_name, "total_amount": total_amount})