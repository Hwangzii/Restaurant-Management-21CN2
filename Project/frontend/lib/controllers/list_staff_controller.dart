import 'package:app/services/api_service.dart';

class ListStaffController {
  // Lấy danh sách nhân viên
  static Future<List<Map<String, dynamic>>> fetchStaffList() async {
    try {
      List<Map<String, dynamic>> data = await ApiService().fetchEmployees();

      // Chuyển đổi dữ liệu nếu cần thiết
      List<Map<String, dynamic>> staffList = data
          .map((employee) => {
                'employees_id': employee['employees_id'],
                'full_name': employee['full_name'],
                'phone_number': employee['phone_number'],
                'date_of_birth': employee['date_of_birth'],
                'employees_address': employee['employees_address'],
                'position': employee['position'],
                'time_start': employee['time_start'],
                'status_work': employee['status_work'], // true/false
                'restaurant': employee['restaurant'],
              })
          .toList();

      return staffList;
    } catch (e) {
      print('Error fetching staff list: $e'); // In lỗi ra console
      throw Exception('Error fetching staff list: $e');
    }
  }

  // Thêm nhân viên mới
  static Future<bool> addStaff({
    required String fullName,
    required String phoneNumber,
    required String dateOfBirth,
    required String address,
    required String position,
    required String timeStart,
    required bool statusWork,
  }) async {
    try {
      bool success = await ApiService().addEmployee(
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        position: position,
        timeStart: timeStart,
        statusWork: statusWork,
      );
      return success;
    } catch (e) {
      print('Error adding staff: $e');
      rethrow; // Ném lại ngoại lệ
    }
  }

  // Sửa thông tin nhân viên
  static Future<bool> updateStaff({
    required int employeeId,
    String? fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? address,
    String? position,
    String? timeStart,
    bool? statusWork,
  }) async {
    try {
      bool success = await ApiService().updateEmployee(
        employeeId: employeeId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        position: position,
        timeStart: timeStart,
        statusWork: statusWork,
      );
      return success;
    } catch (e) {
      print('Error updating staff: $e');
      rethrow;
    }
  }

  // Xóa nhân viên
  static Future<bool> deleteStaff(int employeeId) async {
    try {
      bool success = await ApiService().deleteEmployee(employeeId);
      return success;
    } catch (e) {
      print('Error deleting staff: $e');
      rethrow;
    }
  }
}
