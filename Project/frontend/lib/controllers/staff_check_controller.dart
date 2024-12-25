import 'package:app/services/api_service.dart';
import 'package:intl/intl.dart';

class StaffCheckAppController {
  // Phương thức static để lấy danh sách nhân viên đã lọc
  static Future<List<Map<String, dynamic>>> fetchFilteredEmployees({
    required DateTime selectedDate,
    required String shiftType,
  }) async {
    try {
      final apiService = ApiService(); // Khởi tạo ApiService

      // Lấy danh sách lịch làm việc từ API
      final scheduleResponse = await apiService.fetchWorkSchedules();
      if (scheduleResponse.isEmpty) {
        print("No schedule data available from API");
        return [];
      }
      print("Schedule Response: $scheduleResponse");

      // Lọc danh sách employee_id theo ngày và ca làm việc
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final employeeIds = _filterEmployeeIds(
        scheduleResponse,
        selectedDateStr,
        shiftType == 'ca sáng' ? 'sáng' : 'tối',
      );
      print("Filtered Employee IDs for $selectedDateStr ($shiftType): $employeeIds");

      // Nếu không có employee_id nào khớp, trả về danh sách trống
      if (employeeIds.isEmpty) {
        print("No employee IDs found for the selected date and shift");
        return [];
      }

      // Lấy danh sách nhân viên từ API
      final employeeResponse = await apiService.fetchEmployees();
      if (employeeResponse.isEmpty) {
        print("No employee data available from API");
        return [];
      }
      print("Employee Response: $employeeResponse");

      // Lọc danh sách nhân viên dựa trên danh sách employee_id đã lọc
      final filteredEmployees = _filterEmployees(employeeResponse, employeeIds);
      print("Filtered Employees: $filteredEmployees");

      return filteredEmployees;
    } catch (e) {
      print("Error fetching filtered employees: $e");
      throw Exception("Error fetching filtered employees");
    }
  }

  // Hàm lọc danh sách employee_id từ scheduleData
  static List<int> _filterEmployeeIds(List scheduleData, String date, String shift) {
    return scheduleData
        .where((schedule) {
          // Log từng lịch làm để kiểm tra chi tiết
          print("Schedule being checked: $schedule");
          return schedule['work_date'] == date && schedule['shift_type'] == shift;
        })
        .map<int>((schedule) => int.tryParse(schedule['employee'].toString()) ?? 0)
        .where((employeeId) => employeeId != 0)
        .toList();
  }

  // Hàm lọc thông tin nhân viên từ danh sách employeeData
  static List<Map<String, dynamic>> _filterEmployees(List employeeData, List<int> employeeIds) {
    return employeeData
        .where((employee) {
          // Log từng nhân viên được kiểm tra
          print("Employee being checked: $employee");
          return employeeIds.contains(int.tryParse(employee['employees_id'].toString()) ?? 0);
        })
        .map<Map<String, dynamic>>((employee) => {
              'full_name': employee['full_name'],
              'position': employee['position'],
              'phone_number': employee['phone_number'],
            })
        .toList();
  }
}
