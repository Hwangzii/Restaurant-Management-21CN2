import 'package:app/screens/list_staff_screen.dart';
import 'package:app/screens/payroll_screen.dart';
import 'package:app/screens/shift_registration_screen.dart';
import 'package:app/screens/staff_check_screen.dart';
import 'package:flutter/material.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Quản lý nhân sự',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Thanh ngang mờ ngăn cách
            Container(
              color: Colors.grey[300], // Màu xám nhạt
              height: 1, // Độ dày của thanh ngang
            ),
            // Nội dung chính
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildButton(
                      context,
                      imagePath: 'assets/member-list.png',
                      label: 'Danh sách nhân sự',
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const ListStaffScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      context,
                      imagePath: 'assets/calender.png',
                      label: 'Đăng ký ca làm',
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const ShiftRegistrationScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      context,
                      imagePath: 'assets/staff_check.png',
                      label: 'Điểm danh',
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const StaffCheckScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      context,
                      imagePath: 'assets/money.png',
                      label: 'Thanh toán lương',
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => PayrollScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadowColor: Colors.transparent, // Loại bỏ bóng
        elevation: 0, // Loại bỏ độ cao
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
