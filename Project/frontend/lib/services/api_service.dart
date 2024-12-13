import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      'https://bcff-2001-ee0-40c1-b9f4-5419-cd0a-819d-51ba.ngrok-free.app/api'; // Cập nhật URL API của bạn
       

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

  // Hàm lấy dữ liệu bàn từ API
  Future<List<Map<String, dynamic>>> fetchTables() async {
    final tablesUrl = '$baseUrl/tables/'; // Đường dẫn API lấy danh sách bàn

    try {
      final response = await http.get(Uri.parse(tablesUrl), headers: {
        'Accept': 'application/json', // Đảm bảo yêu cầu JSON
        "ngrok-skip-browser-warning": "69420",
      });

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      throw Exception('Error fetching tables: $e');
    }
  }


  // Hàm thêm bàn
  Future<bool> addTable(String tableName, int floor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tables/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'table_name': tableName, 'floor': floor}),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }

  }

  // Hàm sửa bàn
  Future<bool> updateTableName(int tableId, String newName, int floor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tables/$tableId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'table_name': newName, 'floor': floor}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }


  //Hàm xóa bàn
  Future<bool> deleteTable(int tableId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tables/$tableId/'),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

   
}
