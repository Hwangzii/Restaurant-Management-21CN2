import 'package:app/services/api_service.dart'; // Import ApiService từ thư mục services

class ShiftRegistrationController {
  // Hàm lấy dữ liệu nhân viên từ API
  static Future<List<Map<String, dynamic>>> fetchEmployees() async {
    try {
      // Lấy danh sách nhân viên từ ApiService
      List<Map<String, dynamic>> data = await ApiService().fetchEmployees();

      // Kiểm tra nếu dữ liệu rỗng, ném ra lỗi
      if (data.isEmpty) {
        throw Exception('No staff found');
      }

      // Chuyển đổi dữ liệu nhân viên theo yêu cầu
      return data.map((employee) {
        return {
          'employees_id': employee['employees_id'],
          'full_name': employee['full_name'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching staff list: $e');
      throw Exception('Error fetching staff list');
    }
  }
}
