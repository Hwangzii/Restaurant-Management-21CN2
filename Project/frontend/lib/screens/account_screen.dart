import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Nút quay lại
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        title: Row(
          children: [
            Text(
              'Cài đặt thông tin cá nhân',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
        centerTitle: false, // Căn trái tiêu đề
        backgroundColor: Colors.white, // Màu nền AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh đại diện và tên
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Logic thay đổi ảnh đại diện
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://example.com/your-profile-image.jpg'),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 8), // Khoảng cách giữa ảnh và tên
                  Text(
                    "Nguyễn Hoàng Phi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Thông tin cá nhân với hai cột
            Column(
              children: [
                _buildInfoRow("Khung hình đại diện", "Chưa được đặt"),
                _buildInfoRow("Biệt danh", "Nguyễn Hoàng Phi"),
                _buildInfoRow("Giới tính", "Nam"),
                _buildInfoRow("Địa điểm", "Chưa được đặt"),
                _buildInfoRow("Liên kết điện thoại", "123456789"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget để tạo một hàng thông tin
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Color(0xFFB0B0B0)),
          ),
        ],
      ),
    );
  }
}
