import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
import 'account_screen.dart'; // Đảm bảo import trang AccountScreen

class MenuOptions extends StatelessWidget {
  final User user;

  const MenuOptions({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        title: Row(
          children: [
            Icon(
              Icons.account_circle,
              color: Colors.black54,
              size: 30, // Icon user
            ),
            SizedBox(width: 10), // Khoảng cách giữa icon và tên
            Text(
              '${user.name}', // Tên tài khoản cố định
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
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05), // Đảm bảo căn trái
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Đưa tất cả lên trên
          crossAxisAlignment:
              CrossAxisAlignment.start, // Căn trái cho chữ "Tùy chọn"
          children: [
            SizedBox(height: screenHeight * 0.02), // Khoảng cách từ trên xuống

            // Icon chìa khóa và text "Thay đổi mật khẩu"
            GestureDetector(
              onTap: () {
                // Chuyển tới màn hình ChangePasswordScreen khi ấn vào "Thay đổi mật khẩu"
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(
                            user: user,
                          )),
                );
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/key.png', // Đường dẫn tới ảnh của bạn
                    width: 16, // Kích thước ảnh
                    height: 16,
                  ),
                  SizedBox(width: 15), // Khoảng cách giữa icon và text
                  Text(
                    'Thay đổi mật khẩu', // Văn bản
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
                height: screenHeight * 0.03), // Khoảng cách xuống mục tiếp theo

            // Icon người dùng và text "Quản lý người dùng"
            GestureDetector(
              onTap: () {
                // Chuyển tới màn hình AccountScreen khi ấn vào "Quản lý người dùng"
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AccountScreen()), // Đảm bảo bạn đã tạo AccountScreen
                );
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/clients.png', // Đường dẫn tới ảnh của bạn
                    width: 16, // Kích thước ảnh
                    height: 16,
                  ),
                  SizedBox(width: 15), // Khoảng cách giữa icon và text
                  Text(
                    'Cài đặt thông tin cá nhân', // Văn bản
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
                height: screenHeight * 0.04), // Khoảng cách xuống nút đăng xuất

            // Nút Đăng xuất
            Container(
              width: screenWidth * 0.9, // Chiếm 90% chiều rộng màn hình
              child: ElevatedButton(
                onPressed: () {
                  // Chuyển về màn hình LoginScreen và loại bỏ tất cả màn hình trước đó
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.black, // Chữ màu đen
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF2F2F2), // Màu nền nút
                  elevation: 0, // Loại bỏ bóng đổ
                  shadowColor: Colors.transparent, // Xóa bóng hoàn toàn
                  padding: EdgeInsets.symmetric(
                    vertical: 20, // Chiều cao nút
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Bo tròn nút
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
