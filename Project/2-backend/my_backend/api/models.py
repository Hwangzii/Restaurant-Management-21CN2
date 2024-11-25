from django.db import models

class Account(models.Model):
    username = models.CharField(max_length=50)
    password = models.CharField(max_length=50)

    class Meta:
        db_table = 'Account_tb'  # Đặt tên bảng thủ công
