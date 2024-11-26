# models.py
from django.db import models

class Account(models.Model):
    username = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=100)

    class Meta:
        db_table = 'Account_tb'  # Trỏ đến bảng Account_tb trong SQL Server

    def __str__(self):
        return self.username
