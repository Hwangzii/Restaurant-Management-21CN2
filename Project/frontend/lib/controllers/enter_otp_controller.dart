import 'package:flutter/material.dart';
import 'package:app/screens/manager_screen.dart';
import 'package:app/services/api_service.dart';

class EnterOtpController {
  /// Hàm kiểm tra OTP và xử lý điều hướng
  Future<void> verifyOtp(
      BuildContext context, String username, String otp) async {
    if (otp.length == 6) {
      // Gọi API xác thực OTP
      final result = await ApiService().verifyOtp(username, otp);
      if (result['success']) {
        // Nếu OTP đúng, chuyển sang ManagerScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ManagerScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Mã OTP không hợp lệ! Vui lòng thử lại.')),
        );
      }
    }
  }
}
