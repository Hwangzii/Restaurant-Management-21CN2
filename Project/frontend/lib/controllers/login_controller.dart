// lib/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:app/screens/enter_otp_screen.dart';
import 'package:app/services/api_service.dart';

class LoginController {
  static Future<void> handleLogin(BuildContext context, String username,
      String password, Function(bool) setLoading) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tài khoản và mật khẩu đầy đủ'),
        ),
      );
      return;
    }

    setLoading(true);

    try {
      final loginResult = await ApiService().login(username, password);
      setLoading(false);

      if (loginResult != null && loginResult['success']) {
        if (loginResult['is2faEnabled']) {
          // Nếu người dùng đã bật 2FA, chỉ chuyển đến màn hình OTP (chưa vào Home)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnterOtpScreen(
                qrCodeUrl: '', // Không cần QR code khi đã bật 2FA
                username: username,
              ),
            ),
          );
        } else if (loginResult['qrCodeUrl'] != null) {
          // Nếu chưa bật 2FA, chuyển đến màn hình quét QR code để thiết lập 2FA
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
          // Nếu không cần 2FA, chuyển đến màn hình chính
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Nếu đăng nhập không thành công, hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Tài khoản hoặc mật khẩu không đúng. Vui lòng thử lại!'),
          ),
        );
      }
    } catch (e) {
      setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã có lỗi xảy ra. Vui lòng thử lại sau!'),
        ),
      );
    }
  }
}
