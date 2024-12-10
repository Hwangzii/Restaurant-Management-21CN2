import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      'https://8ca6-14-232-147-119.ngrok-free.app/api'; // Cập nhật URL API của bạn

  // Gửi request đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    final loginUrl = '$baseUrl/login/';

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'is2faEnabled': data['is_2fa_enabled'], // Check if 2FA is enabled
          'qrCodeUrl':
              data['qr_code_url'], // If 2FA enabled, return QR Code URL
        };
      } else {
        return {'success': false};
      }
    } catch (e) {
      print('Error calling API: $e');
      return {'success': false};
    }
  }

  // Gửi request xác thực OTP
  Future<Map<String, dynamic>> verifyOtp(String username, String otp) async {
    final verifyOtpUrl = '$baseUrl/verify_otp/';

    try {
      final response = await http.post(
        Uri.parse(verifyOtpUrl),
        body: {'username': username, 'otp': otp},
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false};
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return {'success': false};
    }
  }
}
