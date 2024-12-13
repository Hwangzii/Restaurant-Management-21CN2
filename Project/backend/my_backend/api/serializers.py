from rest_framework import serializers
from .models import Account, MenuItem, Floors, Tables

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ['id', 'username', 'password','name','restaurant_id','phone_number','email','key','created_at','is_2fa_enabled']  # Các trường bạn muốn trả về

class MenuItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = MenuItem
        fields = ['item_code', 'item_name', 'item_price', 'item_status', 'item_sales_count']
 
class FloorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Floors
        fields = ['floor_id', 'floor_name', 'restaurant_id']

class TableSerializer(serializers.ModelSerializer):
    floor = serializers.SlugRelatedField(
        queryset=Floors.objects.all(),
        slug_field='floor_id'
    )

    class Meta:
        model = Tables
        fields = ['table_id', 'table_name', 'floor']