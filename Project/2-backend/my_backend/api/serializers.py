# serializers.py (nếu sử dụng bảng Account_tb)
from rest_framework import serializers
from .models import Account

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ['id', 'username', 'password']  # Các trường bạn muốn serialize
