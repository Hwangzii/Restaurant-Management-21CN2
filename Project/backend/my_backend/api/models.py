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
    name = models.CharField(max_length=100,null=True, blank=True)
    user_phone = models.CharField(max_length=15,null=True, blank=True)
    email = models.EmailField(max_length=50, null=True, blank=True)  # Sử dụng EmailField để xác thực email
    key = models.CharField(max_length=50, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_2fa_enabled = models.BooleanField(default=False)
    role = models.IntegerField(null=True, blank=True)
    restaurant_id = models.IntegerField(null=True, blank=True)

    class Meta:
        db_table = 'accounts'  # Trỏ đến bảng Account_tb trong SQL Server

    def __str__(self):
        return self.username
    

class MenuItem(models.Model):
    item_id = models.AutoField(primary_key=True)  # Khóa chính tự tăng
    restaurant = models.ForeignKey('Restaurant', on_delete=models.CASCADE)
    item_name = models.CharField(max_length=100)
    item_price = models.DecimalField(max_digits=10, decimal_places=0, null=True, blank=True)
    item_describe = models.CharField(max_length=50, null=True, blank=True)
    item_type = models.IntegerField()  
    item_status = models.BooleanField(default=True)  # 1 = hoạt động, 0 = không hoạt động
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'menu_items'

    def __str__(self):
        return self.item_name


class Floors(models.Model):
    floor_id = models.AutoField(primary_key=True)  # Khóa chính
    floor_name = models.CharField(max_length=100)  # Tên tầng
    restaurant_id = models.IntegerField()  # ID nhà hàng liên kết

    class Meta:
        db_table = 'floors'

    def __str__(self):
        return self.floor_name

class Tables(models.Model):
    table_id = models.AutoField(primary_key=True)  # Khóa chính
    table_name = models.CharField(max_length=100)  # Tên bàn
    status = models.BooleanField(default=False, null=True, blank=True)
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
    restaurant_id = models.IntegerField(default=2, null=2, blank=True)

    class Meta:
        db_table = 'employees'

    def __str__(self):
        return self.full_name


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
    payment_method = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'inventory'  

    def __str__(self):
        return self.item_name
    
class InvoiceFood(models.Model):
    invoice_food_id = models.AutoField(primary_key=True)
    list_item = models.TextField()
    total_amount = models.DecimalField(max_digits=10, decimal_places=0)
    payment_method = models.CharField(max_length=20)
    invoice_type = models.IntegerField(default=1)
    created_at = models.DateTimeField()
    pre_sale_price = models.DecimalField(max_digits=10, decimal_places=0)
    table_name = models.CharField(max_length=20)
    sale_percent = models.IntegerField(null=True, blank=True) 

    class Meta:
        db_table = 'invoice_food'

    def __str__(self):
        return self.invoice_food_id
    
class WorkSchedule(models.Model):
    schedule_id = models.AutoField(primary_key=True)
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='work_schedule')
    work_date = models.DateField()
    shift_type = models.CharField(max_length=50)
    status = models.CharField(max_length=10)
    describe = models.CharField(max_length=50, null= True, blank= True)

    class Meta:
        db_table = 'work_schedule'

    def __str__(self):
        return self.schedule_id

class Customer(models.Model):
    customer_id = models.AutoField(primary_key=True)
    customer_name = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=20)
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
    invoice_type = models.IntegerField(default=2)
    created_at = models.DateTimeField()
    item_id = models.IntegerField(null = True, blank= True)
    quality = models.IntegerField()
    item_name = models.CharField(max_length=255)
    unit = models.CharField(max_length=255)

    class Meta:
        db_table = 'invoice_inventory'
    def __str__(self):
        return self.invoice_inventory_id
    
class InvoiceSalaries(models.Model):
    invoice_salaries_id = models.AutoField(primary_key=True)
    employee_name = models.CharField(max_length=255)
    salaries = models.IntegerField()
    created_at = models.DateTimeField()
    payment_method = models.CharField(max_length=50)
    salary = models.ForeignKey('Salaries', on_delete=models.CASCADE, related_name='invoices')  # Liên kết đến bảng Salaries

    class Meta:
        db_table = 'invoice_salaries'
    def __str__(self):
        return self.invoice_salaries_id
    
class Invoice(models.Model):
    invoice_id = models.AutoField(primary_key=True)
    id = models.IntegerField()
    invoice_type = models.IntegerField()
    describe = models.TextField(null=True, blank=True)
    money = models.IntegerField()
    invoice_name = models.CharField(max_length=255)
    created_at = models.DateTimeField()

    class Meta:
        db_table = 'invoice'
    def __str__(self):
        return self.invoice_id
    
class Salaries(models.Model):
    salary_id = models.AutoField(primary_key=True)
    month = models.CharField(max_length=30)
    salary = models.IntegerField() 
    final_salary = models.IntegerField() 
    penalty = models.IntegerField() 
    deduction = models.IntegerField() 
    payment_date = models.DateTimeField()
    total_timework = models.IntegerField(null=True, blank=True)
    total_timegolate = models.IntegerField(null=True, blank=True)
    employee_name = models.CharField(max_length=255)
    employees = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='Salaries')
    total_late = models.IntegerField()
    total_absent = models.IntegerField()
    total_Permitted_leave = models.IntegerField()
    salary_month = models.IntegerField()
    salary_year = models.IntegerField()
    is_paid = models.BooleanField(default=False)  # Thêm trường trạng thái thanh toán

    class Meta:
        db_table = 'Salaries'
    def __str__(self):
        return self.salary_id
    
class OrderDetails(models.Model):
    table_name = models.CharField(max_length=50)  # Tên bàn
    item_name = models.CharField(max_length=255)  # Tên món ăn
    quantity = models.IntegerField()              # Số lượng
    item_price = models.IntegerField()            # Giá mỗi món
    timestamp = models.DateTimeField(auto_now_add=True)  # Thời gian gọi món
    status = models.CharField(max_length=50, default='Pending')  # Trạng thái món
    buffet_total = models.IntegerField(null=True, blank=True)
    describe = models.TextField(null=True, blank= True)
    type = models.TextField(null= True, blank= True)
    restaurant_id =models.IntegerField(default=2,null=True,blank=True)
    class Meta:
        db_table = 'order_details'
    def __str__(self):
        return f"{self.table_name} - {self.item_name}"
    
    

