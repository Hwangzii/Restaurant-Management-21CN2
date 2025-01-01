import 'package:flutter/material.dart';
import 'package:app/screens/manager_screen.dart';
import 'package:app/screens/tables_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:app/models/user.dart';

class EnterOtpController {
  /// Hàm kiểm tra OTP và xử lý điều hướng
  Future<void> verifyOtp(
      BuildContext context, String username, String otp) async {
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP phải có 6 chữ số!')),
      );
      return;
    }

    try {
      // Gọi API xác thực OTP
      final result = await ApiService().verifyOtp(username, otp);

      // Kiểm tra dữ liệu trả về từ API
      // ignore: unnecessary_null_comparison
      if (result != null &&
          result.containsKey('success') &&
          result['success'] &&
          result.containsKey('role')) {
        // Lấy role từ kết quả trả về
        final accountInfo = await ApiService().getAccountInfo(username);
        int? role = int.tryParse(result['role'].toString());
        print('Role received from API: $role');
        // await AuthService.saveRestaurantId(restaurantId);

        if (role == 1) {
          if (accountInfo != null && accountInfo['success']) {
            // Chuyển đổi dữ liệu từ API thành đối tượng User
            User user = User.fromMap(accountInfo['data']);

            // Chuyển sang ManagerScreen và truyền đối tượng user
            // Role 1: Chuyển đến ManagerScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ManagerScreen(user: user)),
            );
          }
        } else if (role == 2) {
          if (accountInfo != null && accountInfo['success']) {
            User user = User.fromMap(accountInfo['data']);
            // Role 2: Chuyển đến TableScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TablesScreen(user: user)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quyền truy cập không hợp lệ! Vui lòng thử lại.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Mã OTP không hợp lệ hoặc không có dữ liệu role!')),
        );
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi. Vui lòng thử lại.')),
      );
    }
  }
}
