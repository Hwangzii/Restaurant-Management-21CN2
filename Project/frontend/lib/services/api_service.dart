// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://15ac-2401-d800-70c0-2af5-1419-1ec4-c3a7-30a3.ngrok-free.app/api'; // Cập nhật URL API của bạn

  Future<bool> login(String username, String password) async {
    final loginUrl = '$baseUrl/login/';  // Đảm bảo rằng URL login chính xác

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', // Định dạng content type
          'Accept': 'application/json', // Chấp nhận dữ liệu trả về dưới dạng JSON
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Kiểm tra nếu đăng nhập thành công (API có thể trả về thông tin về người dùng hoặc token)
        return true;
      } else {
        // Nếu mã trạng thái không phải 200, trả về false
        return false;
      }
    } catch (e) {
      print('Lỗi khi gọi API: $e');
      return false;  // Nếu có lỗi kết nối hoặc lỗi gì đó, trả về false
    }
  }
}
