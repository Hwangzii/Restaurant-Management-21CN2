import 'package:app/services/api_service.dart';

class PayrollController {
  final ApiService apiService = ApiService(); // Tạo instance của ApiService

  // Hàm lấy danh sách lương và xử lý lỗi
  Future<List<Map<String, dynamic>>> loadSalaries() async {
    try {
      List<Map<String, dynamic>> salaries = await apiService.fetchSalaries();
      return salaries;
    } catch (e) {
      print('Lỗi khi tải danh sách lương: $e');
      return []; // Trả về danh sách trống nếu có lỗi
    }
  }
}
