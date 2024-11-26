import 'package:flutter/material.dart';
import 'package:app/screens/home_screen.dart';

class LoginController {
  static void handleLogin(BuildContext context, String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tài khoản và mật khẩu đầy đủ'),
        ),
      );
    } else if (username == 'admin' && password == '123456') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tài khoản hoặc mật khẩu không đúng. Vui lòng thử lại!'),
        ),
      );
    }
  }
}
