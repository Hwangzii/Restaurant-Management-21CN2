from django.db import models

class Restaurant(models.Model):
    restaurant_id = models.CharField(max_length=10, primary_key=True)
    restaurant_name = models.CharField(max_length=100)

    class Meta:
        db_table = 'restaurants'  # Đảm bảo trùng với tên bảng trong SQL Server

    def __str__(self):
        return self.restaurant_name

class Account(models.Model):
    username = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=255)  # Tăng độ dài để lưu trữ mật khẩu băm
    name = models.CharField(max_length=100)
    user_phone = models.CharField(max_length=15)
    email = models.EmailField(max_length=50)  # Sử dụng EmailField để xác thực email
    key = models.CharField(max_length=50, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_2fa_enabled = models.BooleanField(default=False)

    class Meta:
        db_table = 'accounts'  # Trỏ đến bảng Account_tb trong SQL Server

    def __str__(self):
        return self.username
    
from django.db import models

class MenuItem(models.Model):
    item_id = models.AutoField(primary_key=True)  # Khóa chính tự tăng
    restaurant = models.ForeignKey('Restaurant', on_delete=models.CASCADE)
    item_name = models.CharField(max_length=100)
    item_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    item_describe = models.CharField(max_length=50, null=True, blank=True)
    item_type = models.IntegerField()  # Bạn có thể dùng choices tùy theo nghiệp vụ
    item_status = models.BooleanField(default=False)  # 1 = hoạt động, 0 = không hoạt động
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'menu_items'

    def __str__(self):
        return self.item_name


class Floors(models.Model):
    floor_id = models.AutoField(primary_key=True)  # Khóa chính
    floor_name = models.CharField(max_length=100)  # Tên tầng
    restaurant = models.ForeignKey('Restaurant', on_delete=models.CASCADE)

    class Meta:
        db_table = 'floors'

    def __str__(self):
        return self.floor_name

class Tables(models.Model):
    table_id = models.AutoField(primary_key=True)  # Khóa chính
    table_name = models.CharField(max_length=100)  # Tên bàn
    floor = models.ForeignKey(Floors, on_delete=models.CASCADE, related_name='tables')  # Liên kết với Floors

    class Meta:
        db_table = 'tables'

    def __str__(self):
        return self.table_name

class Employee(models.Model):
    employees_id = models.AutoField(primary_key=True)
    full_name = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=15)
    date_of_birth = models.DateField()
    employees_address = models.CharField(max_length=255)
    position = models.CharField(max_length=50)
    time_start = models.DateField()
    status_work = models.BooleanField(default=True)
    cccd = models.CharField(max_length=100)
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='employees')

    class Meta:
        db_table = 'employees'

    def __str__(self):
        return self.full_name

from django.db import models

class Inventory(models.Model):
    item_id = models.AutoField(primary_key=True)  # Khóa chính tự tăng
    item_name = models.CharField(max_length=100)
    item_type = models.IntegerField()
    quantity = models.IntegerField()
    exp_item = models.DateField()
    inventory_status = models.BooleanField()
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='items')

    class Meta:
        db_table = 'inventory'  # Đảm bảo trùng với tên bảng trong SQL Server

    def __str__(self):
        return self.item_name

