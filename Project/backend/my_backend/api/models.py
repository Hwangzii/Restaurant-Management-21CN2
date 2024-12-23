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
    item_price = models.DecimalField(max_digits=10, decimal_places=0, null=True, blank=True)
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
    price = models.IntegerField()
    unit = models.CharField(max_length=50)
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='items')

    class Meta:
        db_table = 'inventory'  

    def __str__(self):
        return self.item_name
    
class InvoiceFood(models.Model):
    invoice_food_id = models.IntegerField(primary_key=True)
    list_item = models.CharField(max_length=1)
    total_amount = models.DecimalField(max_digits=10, decimal_places=0)
    payment_method = models.IntegerField()
    invoice_type = models.IntegerField()
    created_at = models.DateTimeField()
    sale_price = models.DecimalField(max_digits=10, decimal_places=0)
    table_name = models.CharField(max_length=20)

    class Meta:
        db_table = 'invoice_food'

    def __str__(self):
        return self.invoice_food_id
    
class WorkSchedule(models.Model):
    schedule_id = models.AutoField(primary_key=True)
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='work_schedule')
    work_date = models.DateField()
    shift_type = models.CharField(max_length=50)
    shift_start = models.TimeField()
    shift_end = models.TimeField()

    class Meta:
        db_table = 'work_schedule'

    def __str__(self):
        return self.schedule_id

class Customer(models.Model):
    customer_id = models.AutoField(primary_key=True)
    customer_name = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=20)
    email = models.CharField(max_length=100)
    loyalty_status = models.BooleanField(default=False)
    counts = models.IntegerField()
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='customer')

    class Meta:
        db_table = 'customers'

    def __str__(self):
        return self.customer_id
    
class InvoiceInventory(models.Model):
    invoice_inventory_id = models.AutoField(primary_key=True)
    total_amount = models.DecimalField(max_digits=10, decimal_places=0)
    payment_method = models.CharField(max_length=30)
    invoice_type = models.IntegerField()
    created_at = models.DateTimeField()
    item = models.ForeignKey(Inventory, on_delete=models.CASCADE, related_name='item')

    class Meta:
        db_table = 'invoice_inventory'
    def __str__(self):
        return self.invoice_inventory_id
    
class Salaries(models.Model):
    salary_id = models.AutoField(primary_key=True)
    month = models.CharField(max_length=30)
    salary = models.DecimalField(max_digits=10, decimal_places=0)
    bonus = models.DecimalField(max_digits=10, decimal_places=0)
    penalty = models.DecimalField(max_digits=10, decimal_places=0)
    deduction = models.DecimalField(max_digits=10, decimal_places=0)
    payment_date = models.DateTimeField()
    employees = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='Salaries')

    class Meta:
        db_table = 'Salaries'
    def __str__(self):
        return self.salary_id

