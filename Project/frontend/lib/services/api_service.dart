import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      'https://2709-123-16-72-60.ngrok-free.app/api'; // Cập nhật URL API của bạn
       

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


  // Hàm lấy dữ liệu thức ăn từ API
  Future<List<Map<String, dynamic>>> fetchOder() async {
    final oderUrl = '$baseUrl/menu_items/'; // đường dẫn lấy API menu

    try {
      final response = await http.get(Uri.parse(oderUrl), headers: {
        'Accept': 'application/json; charset=UTF-8',
        "ngrok-skip-browser-warning": "69420",
      });

      if ( response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(decodedResponse); 
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Lỗi khi tải danh sách món ăn');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu món ăn: $e');
    }
  }

  
  // Hàm thêm thức ăn
  Future<bool> addFood(String itemName, double itemPrice) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menu_items/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'item_name': itemName,
        'item_price': itemPrice,  // Chuyển giá thành chuỗi
        'item_status': true,  // Mặc định là có sẵn
        'item_sales_count': 0  // Mặc định số lượng bán là 0
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Lỗi khi thêm món ăn: ${response.statusCode}');
    }
  }


  

   
}
