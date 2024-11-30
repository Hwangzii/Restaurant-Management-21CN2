import 'package:flutter/material.dart';
import 'package:app/screens/manager_screen.dart';
import 'package:app/screens/enter_otp_screen.dart'; // Import màn hình nhập OTP
import 'package:app/services/api_service.dart'; // Đảm bảo rằng bạn import ApiService

class LoginController {
  static void handleLogin(
      BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tài khoản và mật khẩu đầy đủ'),
        ),
      );
    } else {
      // Gọi API để kiểm tra đăng nhập
      try {
        final loginResult = await ApiService().login(username, password);

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
            // } else {
            //   // Nếu không cần OTP, chuyển đến màn hình chính ngay lập tức
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => const ManagerScreen()),
            //   );
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
        // Nếu có lỗi khi gọi API, hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã có lỗi xảy ra. Vui lòng thử lại sau!'),
          ),
        );
      }
    }
  }
}
