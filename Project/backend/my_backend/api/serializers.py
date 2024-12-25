from rest_framework import serializers
from .models import Account, Customer, Employee, Inventory, InvoiceFood, InvoiceInventory, MenuItem, Floors, OrderDetails, Restaurant, Salaries, Tables, WorkSchedule

class RestaurantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Restaurant
        fields = ['restaurant_id', 'restaurant_name']

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ['id', 'username', 'password','name','user_phone','email','key','created_at','is_2fa_enabled','role','restaurant_id']  # Các trường bạn muốn trả về

class MenuItemSerializer(serializers.ModelSerializer):
    restaurant = serializers.SlugRelatedField(
        queryset=Restaurant.objects.all(),
        slug_field='restaurant_id'
    )
    item_price_formatted = serializers.SerializerMethodField()  # Thêm dòng này

    class Meta:
        model = MenuItem
        fields = [
            'item_id',
            'restaurant',
            'item_name',
            'item_price',
            'item_price_formatted',  # Trường custom phải có trong fields
            'item_describe',
            'item_type',
            'item_status',
            'created_at',
            'updated_at'
        ]

    def get_item_price_formatted(self, obj):
        if obj.item_price is None:
        # Nếu không có giá, bạn có thể trả về chuỗi rỗng, hoặc "0.000"
            return ""
        float_price = float(obj.item_price)
        adjusted_price = float_price / 1000
        return f"{adjusted_price:.3f}"
        

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
        fields = ['table_id', 'table_name', 'floor', 'status']

class EmployeeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employee
        fields = '__all__'

class InventorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Inventory
        fields = '__all__'

class InvoiceFooodSerializer(serializers.ModelSerializer):
    class Meta:
        model = InvoiceFood
        fields = '__all__'

class WorkScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkSchedule
        fields = '__all__'

class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = '__all__'

class InvoiceInventorySerializer(serializers.ModelSerializer):
    class Meta:
        model = InvoiceInventory
        fields = '__all__'

class SalariesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Salaries
        fields = '__all__'

class OrderDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderDetails
        fields = '__all__'  