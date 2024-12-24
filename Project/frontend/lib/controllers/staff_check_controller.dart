import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Thêm thư viện để xử lý ngày tháng

class StaffCheckAppController {
  final String scheduleApiUrl = 'https://0e2c-14-244-179-113.ngrok-free.app/api/work_schedule/';
  final String employeeApiUrl = 'https://0e2c-14-244-179-113.ngrok-free.app/api/employees/';

  Future<List<Map<String, dynamic>>> fetchFilteredEmployees({
    required DateTime selectedDate,
    required String shiftType,
  }) async {
    // 1. Gọi API lịch làm việc
    final scheduleResponse = await http.get(Uri.parse(scheduleApiUrl));
    if (scheduleResponse.statusCode != 200) {
      print('Schedule API Error: ${scheduleResponse.body}');
      throw Exception('Failed to load schedules with status code ${scheduleResponse.statusCode}');
    }
    // Giải mã dữ liệu từ API với UTF-8
    final scheduleData = jsonDecode(utf8.decode(scheduleResponse.bodyBytes)) as List;

    // Log toàn bộ dữ liệu trả về từ API
    print("Schedule Data from API: $scheduleData");

    // Định dạng ngày thành chuỗi
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Lọc danh sách employee_id theo ngày và ca làm việc
    final employeeIds = _filterEmployeeIds(
      scheduleData,
      selectedDateStr,
      shiftType == 'ca sáng' ? 'sáng' : 'tối',
    );

    print("Filtered Employee IDs for $selectedDateStr ($shiftType): $employeeIds");

    // 2. Gọi API danh sách nhân viên
    final employeeResponse = await http.get(Uri.parse(employeeApiUrl));
    if (employeeResponse.statusCode != 200) {
      print('Employee API Error: ${employeeResponse.body}');
      throw Exception('Failed to load employees with status code ${employeeResponse.statusCode}');
    }
    // Giải mã dữ liệu từ API với UTF-8
    final employeeData = jsonDecode(utf8.decode(employeeResponse.bodyBytes)) as List;

    // Log toàn bộ dữ liệu trả về từ API
    print("Employee Data from API: $employeeData");

    // Lọc thông tin nhân viên dựa trên employee_id
    final filteredEmployees = _filterEmployees(employeeData, employeeIds);

    print("Filtered Employees for $selectedDateStr ($shiftType): $filteredEmployees");
    return filteredEmployees;
  }

  // Hàm lọc danh sách employee_id từ scheduleData
  List<int> _filterEmployeeIds(List scheduleData, String date, String shift) {
    return scheduleData
        .where((schedule) =>
            schedule['work_date'] == date &&
            schedule['shift_type'] == shift)
        .map<int>((schedule) => schedule['employee'])
        .toList();
  }

  // Hàm lọc thông tin nhân viên từ danh sách employeeData
  List<Map<String, dynamic>> _filterEmployees(List employeeData, List<int> employeeIds) {
    return employeeData
        .where((employee) => employeeIds.contains(employee['employees_id']))
        .map<Map<String, dynamic>>((employee) => {
              'full_name': employee['full_name'],
              'position': employee['position'],
              'phone_number': employee['phone_number'],
            })
        .toList();
  }
}
