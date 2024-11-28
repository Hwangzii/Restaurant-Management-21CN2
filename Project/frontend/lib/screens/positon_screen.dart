import 'package:flutter/material.dart';
import 'login_screen.dart';

class PositionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              'Chức vụ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8), // Khoảng cách
            // Mô tả
            Text(
              'Vui lòng chọn chức vụ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16), // Khoảng cách
            // Danh sách button
            Column(
              children: [
                // Nút "Quản lý"
                buildPositionButton('Quản lý', context),
                SizedBox(height: 12), // Khoảng cách
                // Nút "Phòng bếp"
                buildPositionButton('Phòng bếp', context),
                SizedBox(height: 12), // Khoảng cách
                // Nút "Nhân viên"
                buildPositionButton('Nhân viên', context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo button với sự kiện chuyển đến LoginScreen
  Widget buildPositionButton(String title, BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        navigateToLoginScreen(context, title);
      },
      child: Row(
        children: [
          // Chữ tiêu đề
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Spacer(), // Đẩy icon sang phải
          // Icon mũi tên
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  // Hàm chuyển đến LoginScreen
  void navigateToLoginScreen(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}
