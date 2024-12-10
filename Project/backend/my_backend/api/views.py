import pyotp
import secrets
from rest_framework import viewsets, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Account, Floors, MenuItem, Tables
from .serializers import AccountSerializer, FloorSerializer, MenuItemSerializer, TableSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken

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
def verify_otp(secret_key, otp):
    totp = pyotp.TOTP(secret_key)
    return totp.verify(otp)  # Kiểm tra OTP

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
            if verify_otp(account.key, otp):
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


# View để tạo tài khoản mới (Signup)
class SignupView(APIView):
    def post(self, request):
        # Nhận thông tin từ body request
        username = request.data.get('username')
        password = request.data.get('password')

        # Kiểm tra nếu người dùng đã tồn tại
        if Account.objects.filter(username=username).exists():
            return Response({'error': 'Username already exists'}, status=status.HTTP_400_BAD_REQUEST)

        # Tạo tài khoản mới
        account = Account.objects.create(username=username, password=password)
        
        # Tạo token cho người dùng mới
        tokens = get_tokens_for_user(account)

        return Response({'message': 'User created successfully', 'tokens': tokens}, status=status.HTTP_201_CREATED)


# View để quản lý tài khoản người dùng
class AccountListView(APIView):
    def get(self, request):
        # Lấy tất cả tài khoản từ bảng Account_tb
        accounts = Account.objects.all()  
        serializer = AccountSerializer(accounts, many=True)
        return Response(serializer.data)

    def post(self, request):
        # Nhận dữ liệu từ client và lưu tài khoản người dùng
        serializer = AccountSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# API lấy danh sách món ăn và thêm món ăn mới
class MenuItemList(APIView):
    def get(self, request):
        menu_items = MenuItem.objects.all()
        serializer = MenuItemSerializer(menu_items, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = MenuItemSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
# API lấy thông tin chi tiết, cập nhật và xóa món ăn
class MenuItemDetail(APIView):
    def get_object(self, pk):
        try:
            return MenuItem.objects.get(pk=pk)
        except MenuItem.DoesNotExist:
            return None

    def get(self, request, pk):
        menu_item = self.get_object(pk)
        if not menu_item:
            return Response({'error': 'Menu item not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = MenuItemSerializer(menu_item)
        return Response(serializer.data)

    def put(self, request, pk):
        menu_item = self.get_object(pk)
        if not menu_item:
            return Response({'error': 'Menu item not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = MenuItemSerializer(menu_item, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        menu_item = self.get_object(pk)
        if not menu_item:
            return Response({'error': 'Menu item not found'}, status=status.HTTP_404_NOT_FOUND)
        menu_item.delete()
        return Response({'message': 'Menu item deleted successfully'}, status=status.HTTP_204_NO_CONTENT)
    
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