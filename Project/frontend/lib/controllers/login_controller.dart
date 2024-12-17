import 'package:app/services/api_service.dart';
import 'package:app/screens/enter_otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  static void handleLogin(
      BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tài khoản và mật khẩu đầy đủ'),
        ),
      );
      return;
    }

    try {
      final loginResult = await ApiService().login(username, password);
      if (loginResult['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('account_id', loginResult['id']);
        if (loginResult['qrCodeUrl'] != null) {
          // Nếu có QR code (người dùng chưa bật 2FA)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnterOtpScreen(
                qrCodeUrl: loginResult['qrCodeUrl'], // Chuyển QR code
                username: username, // Truyền username
              ),
            ),
          );
        } else {
          // Nếu có QR code (người dùng chưa bật 2FA)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnterOtpScreen(
                qrCodeUrl: '', // Chuyển QR code
                username: username, // Truyền username
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tài khoản hoặc mật khẩu không đúng')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi, vui lòng thử lại')),
      );
    }
  }
}
