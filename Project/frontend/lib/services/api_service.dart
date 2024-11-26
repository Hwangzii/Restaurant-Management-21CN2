// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';

class ApiService {
  final String baseUrl = 'https://15ac-2401-d800-70c0-2af5-1419-1ec4-c3a7-30a3.ngrok-free.app/api/accounts/?format=json';

  Future<List<Account>> fetchAccounts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Account.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load accounts');
    }
  }

  Future<bool> login(String username, String password) async {
    // Đây là ví dụ về một yêu cầu đăng nhập, bạn cần thay đổi endpoint phù hợp
    final loginUrl = '$baseUrl/login/';
    final response = await http.post(
      Uri.parse(loginUrl),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      // Kiểm tra đăng nhập thành công dựa vào response
      return true;
    } else {
      return false;
    }
  }
}
