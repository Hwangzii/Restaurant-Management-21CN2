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
    
    class Meta:
        db_table = 'Account_tb'  # Trỏ đến bảng Account_tb trong SQL Server

    def __str__(self):
        return self.username
