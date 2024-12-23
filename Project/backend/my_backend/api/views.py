import pyotp
import secrets
from rest_framework import viewsets, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Account, Customer, Employee, Floors, Inventory, InvoiceFood, InvoiceInventory, MenuItem, Salaries, Tables, WorkSchedule
from .serializers import AccountSerializer, CustomerSerializer, EmployeeSerializer, FloorSerializer, InventorySerializer, InvoiceFooodSerializer, InvoiceInventorySerializer, MenuItemSerializer, SalariesSerializer, TableSerializer, WorkScheduleSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.viewsets import ReadOnlyModelViewSet, ModelViewSet

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

# View để xác thực OTP và cấp JWT token
class VerifyOTPView(APIView):

    def post(self, request):
        username = request.data.get('username')
        otp = request.data.get('otp')
        
        try:
            account = Account.objects.get(username=username)

            # Xác thực OTP với mã bí mật của người dùng
            if verify_otp(account.key, otp, window=1):
                # Sau khi xác thực OTP, cấp JWT token cho người dùng
                tokens = get_tokens_for_user(account)
                account.is_2fa_enabled = True
                account.save()
                return Response({
                    'message': 'OTP verified successfully',
                    'tokens': tokens
                }, status=status.HTTP_200_OK)
            else:
                return Response({'error': 'Invalid OTP'}, status=status.HTTP_400_BAD_REQUEST)

        except Account.DoesNotExist:
            return Response({'error': 'Account not found'}, status=status.HTTP_404_NOT_FOUND)

# View để quản lý tài khoản người dùng
class AccountViewSet(ReadOnlyModelViewSet):
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

class CustomerViewSet(viewsets.ModelViewSet):
    queryset = Customer.objects.all()
    serializer_class = CustomerSerializer

class InvoiceInventoryViewSet(viewsets.ModelViewSet):
    queryset = InvoiceInventory.objects.all()
    serializer_class = InvoiceInventorySerializer

class SalariesViewSet(viewsets.ModelViewSet):
    queryset = Salaries.objects.all()
    serializer_class = SalariesSerializer