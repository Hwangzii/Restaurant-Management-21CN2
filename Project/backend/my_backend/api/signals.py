from django.db.models.signals import post_save
from django.dispatch import receiver
from django.db.models import Count, Q
from datetime import datetime
from django.utils.timezone import now
from .models import Inventory, InvoiceInventory, WorkSchedule, Salaries, Employee

@receiver(post_save, sender=WorkSchedule)
def calculate_salary(sender, instance, **kwargs):
    try:
        # Lấy danh sách các tháng và năm có dữ liệu trong bảng WorkSchedule
        months_data = WorkSchedule.objects.values('work_date__year', 'work_date__month').distinct()

        for month_data in months_data:
            year = month_data['work_date__year']
            month = month_data['work_date__month']

            start_date = datetime(year, month, 1)
            if month < 12:
                end_date = datetime(year, month + 1, 1)
            else:
                end_date = datetime(year + 1, 1, 1)

            # Lấy danh sách nhân viên và thống kê số ca làm việc trong tháng
            employees = WorkSchedule.objects.filter(
                work_date__gte=start_date, work_date__lt=end_date
            ).values('employee_id').annotate(
                total_present=Count('status', filter=Q(status="có")),
                total_late=Count('status', filter=Q(status="muộn")),
                total_absent=Count('status', filter=Q(status="nghỉ không phép")),
                total_Permitted_leave=Count('status', filter=Q(status="nghỉ có phép"))
            )

            # Tính lương cho từng nhân viên
            for employee in employees:
                employee_id = employee['employee_id']

                # Lấy tên nhân viên từ bảng `Employee`
                employee_obj = Employee.objects.filter(employees_id=employee_id).first()
                employee_name = employee_obj.full_name if employee_obj else "Unknown"

                total_present = employee['total_present']
                total_late = employee['total_late']
                total_absent = employee['total_absent']
                total_Permitted_leave = employee['total_Permitted_leave']

                # Công thức tính lương
                hourly_rate = 20000  # Mỗi giờ làm 20,000 VND
                work_hours = total_present * 5  # Mỗi ca "có" tương đương 5 giờ
                salary = work_hours * hourly_rate

                # Phạt số lần muộn
                if total_late > 3:
                    penalty = total_late * 60000  # Phạt 60,000 nếu quá 3 lần
                else:
                    penalty = total_late * 50000  # Phạt 50,000 nếu <= 3 lần

                # Trừ lương do vắng không phép
                deduction = total_absent * 100000  # Mỗi lần vắng không phép trừ 100,000 VND

                # Tổng lương sau khi trừ phạt và khấu trừ
                total_salary = salary - penalty - deduction

                # Lưu hoặc cập nhật lương trong bảng `salaries`
                Salaries.objects.update_or_create(
                    employees_id=employee_id,
                    month=start_date,
                    defaults={
                        'employee_name': employee_name,
                        'total_timework': work_hours,
                        'total_timegolate': total_late,
                        'salary': total_salary,
                        'final_salary': salary,  
                        'penalty': penalty,
                        'deduction': deduction,
                        'payment_date': now(),
                        'total_late': total_late,
                        'total_absent': total_absent,
                        'total_Permitted_leave': total_Permitted_leave,
                        'salary_month': start_date.month,
                        'salary_year': start_date.year,
                    }
                )

        print("Salary calculation completed for all available months.")

    except Exception as e:
        print(f"Error calculating salary: {e}")

@receiver(post_save, sender=Inventory)
def create_invoice_from_inventory(sender, instance, created, **kwargs):
    if created:  # Chỉ xử lý khi bản ghi mới được tạo
        try:
            InvoiceInventory.objects.create(
                item_id=instance.item_id,
                item_name=instance.item_name,
                total_amount=instance.price * instance.quantity,  # Tổng giá trị
                payment_method=instance.payment_method,
                invoice_type=2,  # Giá trị mặc định
                created_at=instance.created_at,
                quality=instance.quantity,
                unit=instance.unit
            )
            print(f"Invoice created for item {instance.item_id}")
        except Exception as e:
            print(f"Error creating invoice: {e}")