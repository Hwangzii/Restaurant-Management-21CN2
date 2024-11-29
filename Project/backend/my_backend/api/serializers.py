from rest_framework import serializers
from .models import Account

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ['id', 'username', 'password','name','restaurant_id','phone_number','email','key','created_at']  # Các trường bạn muốn trả về
