import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:app/services/api_service.dart';

class AccountScreen extends StatefulWidget {
  final User user;

  const AccountScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? accountInfo; // Lưu thông tin tài khoản
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccountInfo(); // Gọi API khi màn hình được khởi tạo
  }

  // Hàm lấy thông tin tài khoản
  Future<void> _fetchAccountInfo() async {
    try {
      final result = await ApiService().getAccountInfo(widget.user.username);
      if (result != null && result['success'] == true) {
        setState(() {
          accountInfo = result['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(result?['message'] ?? 'Lỗi lấy thông tin tài khoản')),
        );
      }
    } catch (e) {
      print("Error fetching account info: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi lấy thông tin tài khoản')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Hiển thị loading khi đang lấy dữ liệu
          : accountInfo == null
              ? Center(child: Text("Không thể lấy thông tin tài khoản"))
              : Padding(
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
                                backgroundImage:
                                    AssetImage('assets/avatar.png'),
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                            SizedBox(height: 8), // Khoảng cách giữa ảnh và tên
                            Text(
                              accountInfo!['name'], // Hiển thị tên từ API
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
                          _buildInfoRow(
                              "Tên đăng nhập", accountInfo!['username']),
                          _buildInfoRow("Số điện thoại", accountInfo!['phone']),
                          _buildInfoRow("Email", accountInfo!['email']),
                          _buildInfoRow(
                              "Ngày tạo tài khoản",
                              accountInfo!['createdAt']
                                  .toString()
                                  .substring(0, 10)), // Hiển thị ngày tạo
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
