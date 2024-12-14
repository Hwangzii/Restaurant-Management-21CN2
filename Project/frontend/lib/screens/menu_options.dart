import 'package:flutter/material.dart';
import 'login_screen.dart';

class MenuOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF2F3F4),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        title: Text(
          'Tùy chọn', // Tiêu đề AppBar
          style: TextStyle(
            fontSize: 18, // Đổi kích thước phù hợp
          ),
        ),
        centerTitle: false, 
        titleSpacing: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05), // Đảm bảo căn trái
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Đưa tất cả lên trên
            crossAxisAlignment:
                CrossAxisAlignment.start, // Căn trái cho chữ "Tùy chọn"
            children: [
              SizedBox(
                  height: screenHeight *
                      0.02), // Khoảng cách từ trên xuống (giảm xuống)
              // Nút Đăng xuất
              Container(
                width: screenWidth * 0.9, // Chiếm 90% chiều rộng màn hình
                child: ElevatedButton(
                  onPressed: () {
                    // Chuyển về màn hình LoginScreen và loại bỏ tất cả màn hình trước đó
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) =>
                          false, // Loại bỏ tất cả các màn hình trước đó
                    );
                  },
                  child: Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.black, // Chữ màu đen
                      fontSize: 20,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFFFFF), // Màu nút trắng
                    padding: EdgeInsets.symmetric(
                      vertical: 15, // Chiều cao nút
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Bo tròn nút
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
