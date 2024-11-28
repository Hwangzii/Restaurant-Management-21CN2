// controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:app/screens/manager_screen.dart';
import 'package:app/services/api_service.dart'; // Đảm bảo rằng bạn import ApiService

class LoginController {
  static void handleLogin(BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tài khoản và mật khẩu đầy đủ'),
        ),
      );
    } else {
      // Gọi API để kiểm tra đăng nhập
      bool isLoggedIn = await ApiService().login(username, password);

      if (isLoggedIn) {
        // Nếu đăng nhập thành công, chuyển đến màn hình Home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManagerScreen()),
        );
      } else {
        // Nếu đăng nhập không thành công, hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản hoặc mật khẩu không đúng. Vui lòng thử lại!'),
          ),
        );
      }
    }
  }
}
