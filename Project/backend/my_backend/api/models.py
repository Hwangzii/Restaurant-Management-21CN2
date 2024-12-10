from django.db import models

class Account(models.Model):
    username = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=100)
    name = models.CharField(max_length=100)
    restaurant_id = models.CharField(max_length=10)
    phone_number = models.CharField(max_length=15)
    email = models.CharField(max_length=50)
    key = models.CharField(max_length=50, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)  # Chỉnh sửa trường này thành DateTimeField
    is_2fa_enabled = models.BooleanField(default=False)
    
    class Meta:
        db_table = 'Account_tb'  # Trỏ đến bảng Account_tb trong SQL Server

    def __str__(self):
        return self.username
    
class MenuItem(models.Model):
    item_code = models.CharField(max_length=50, primary_key=True)  # Đặt item_code làm khóa chính
    item_name = models.CharField(max_length=100)  # Tên món ăn
    item_price = models.DecimalField(max_digits=10, decimal_places=2)  # Giá món ăn
    item_status = models.BooleanField(default=True)  # Trạng thái món ăn (còn hoạt động hay không)
    item_sales_count = models.IntegerField(default=0)  # Số lượng bán

    class Meta:
        db_table = 'menu_items'  # Sửa tên bảng thành 'menu_items'
        
    def __str__(self):
        return self.item_name

class Floors(models.Model):
    floor_id = models.CharField(max_length=50, primary_key=True)  # Khóa chính
    floor_name = models.CharField(max_length=100)  # Tên tầng
    restaurant_id = models.CharField(max_length=10)  # ID nhà hàng

    class Meta:
        db_table = 'floors'

    def __str__(self):
        return self.floor_name

class Tables(models.Model):
    table_id = models.CharField(max_length=50, primary_key=True)  # Khóa chính
    table_name = models.CharField(max_length=100)  # Tên bàn
    floor = models.ForeignKey(Floors, on_delete=models.CASCADE, related_name='tables')  # Liên kết với Floors

    class Meta:
        db_table = 'tables'

    def __str__(self):
        return self.table_name



