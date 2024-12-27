import 'package:app/services/api_service.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày tháng nếu cần

class ListStaffController {
  /// Lấy danh sách nhân viên
  static Future<List<Map<String, dynamic>>> fetchStaffList() async {
    try {
      List<Map<String, dynamic>> data = await ApiService().fetchEmployees();
      // Kiểm tra dữ liệu trả về từ API
      if (data.isEmpty) {
        throw Exception('No staff found');
      }
      return data.map((employee) {
        return {
          'employees_id': employee['employees_id'],
          'full_name': employee['full_name'],
          'phone_number': employee['phone_number'],
          'date_of_birth': employee['date_of_birth'],
          'employees_address': employee['employees_address'],
          'position': employee['position'],
          'time_start': employee['time_start'],
          'status_work': employee['status_work'],
          'cccd': employee['cccd'],
          'restaurant': employee['restaurant'],
          'status_check': employee['status_check']
        };
      }).toList();
    } catch (e) {
      print('Error fetching staff list: $e');
      throw Exception('Error fetching staff list');
    }
  }

  /// Thêm nhân viên mới
  static Future<bool> addStaff({
    required String fullName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String address,
    required String position,
    required String cccd,
    required DateTime timeStart,
    bool statusWork = true, // Thêm trường statusWork với giá trị mặc định
  }) async {
    try {
      return await ApiService().addEmployee(
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        position: position,
        timeStart: timeStart,
        cccd: cccd,
      );
    } catch (e) {
      print('Error adding staff: $e');
      return false;
    }
  }

  /// Sửa thông tin nhân viên
  static Future<bool> updateStaff({
    required int employeeId,
    required String fullName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String address,
    required String position,
    required String cccd,
    required DateTime timeStart,
    required bool statusWork,
  }) async {
    try {
      // Tạo map chứa dữ liệu đã cập nhật với các giá trị không thể null
      Map<String, dynamic> updatedData = {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'date_of_birth': DateFormat('yyyy-MM-dd').format(dateOfBirth),
        'employees_address': address,
        'position': position,
        'cccd': cccd,
        'time_start': DateFormat('yyyy-MM-dd').format(timeStart),
        'status_work': statusWork,
      };

      // Có thể thêm các kiểm tra bổ sung ở đây nếu cần

      return await ApiService().updateEmployee(
        employeeId: employeeId,
        updatedData: updatedData,
      );
    } catch (e) {
      print('Error updating staff: $e');
      return false;
    }
  }

  /// Xóa nhân viên
  static Future<bool> deleteStaff(int employeeId) async {
    try {
      // Bạn có thể thêm xác nhận từ người dùng ở đây nếu cần
      return await ApiService().deleteEmployee(employeeId);
    } catch (e) {
      print('Error deleting staff: $e');
      return false;
    }
  }
}
