from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Account
from .serializers import AccountSerializer
from rest_framework_simplejwt.tokens import RefreshToken

# Tạo token cho người dùng (JWT)
def get_tokens_for_user(account):
    refresh = RefreshToken.for_user(account)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

# View để đăng nhập người dùng
class LoginView(APIView):
    def post(self, request):
        # Nhận username và password từ body request
        username = request.data.get('username')
        password = request.data.get('password')

        # Kiểm tra thông tin đăng nhập (dùng Account thay vì User)
        try:
            account = Account.objects.get(username=username, password=password)
            tokens = get_tokens_for_user(account)
            return Response({'message': 'Login successful', 'tokens': tokens}, status=status.HTTP_200_OK)
        except Account.DoesNotExist:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)

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
        tokens = get_tokens_for_user(account)  # Tạo token cho người dùng mới
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
