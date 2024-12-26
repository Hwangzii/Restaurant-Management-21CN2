import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayrollScreen extends StatefulWidget {
  @override
  _PayrollScreenState createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  DateTime? selectedDate;
  TextEditingController searchController = TextEditingController(); 
  bool isSearchVisible = false; // Điều khiển thanh tìm kiếm
  List<Map<String, dynamic>> payrollData = [];  // Danh sách bảng lương

  @override
  void initState() {
    super.initState();
    _fetchPayrollData();  // Gọi phương thức lấy dữ liệu API
  }

  // Hàm lấy dữ liệu từ API và xử lý bảng lương
  Future<void> _fetchPayrollData() async {
    try {
      final apiService = ApiService();  // Khởi tạo ApiService
      final employeeResponse = await apiService.fetchEmployees();  // Lấy danh sách nhân viên
      final scheduleResponse = await apiService.fetchWorkSchedules();  // Lấy danh sách lịch làm việc

      if (employeeResponse.isEmpty || scheduleResponse.isEmpty) {
        print("Dữ liệu không hợp lệ");
        return;
      }

      // Tạo bảng lương từ dữ liệu nhân viên và lịch làm việc
      List<Map<String, dynamic>> payrollList = [];

      for (var employee in employeeResponse) {
        int employeeId = employee['employees_id'];
        String fullName = employee['full_name'];

        // Lọc lịch làm việc của nhân viên theo ngày và ca
        List<dynamic> employeeSchedules = scheduleResponse
            .where((schedule) => schedule['employee'] == employeeId)
            .toList();

        // Tính toán số giờ làm việc, nghỉ phép, phạt...
        int workingHours = 0;  // Tổng số giờ làm việc
        int lateHours = 0;     // Tổng số giờ làm muộn
        int daysOff = 0;       // Số ngày nghỉ
        int unauthorizedAbsence = 0; // Số lần nghỉ không phép
        int penalty = 0;       // Tiền phạt

        // Duyệt qua các lịch làm việc và tính toán
        for (var schedule in employeeSchedules) {
          String shiftType = schedule['shift_type'];
          DateTime workDate = DateTime.parse(schedule['work_date']);
          
          // Tính giờ làm dựa trên ca sáng và ca tối
          if (shiftType == 'sáng') {
            workingHours += 4; // Giả sử ca sáng là 4 giờ
          } else if (shiftType == 'tối') {
            workingHours += 4; // Giả sử ca tối là 4 giờ
          }

          // Tính phạt (giả sử phạt 50000 cho mỗi giờ làm muộn)
          if ((schedule['is_late'] ?? false) == true) {
            lateHours++;
            penalty += 50000;  // Phạt muộn
          }

          // Tính ngày nghỉ (giả sử nghỉ phép được tính từ lịch làm việc)
          if ((schedule['is_day_off'] ?? false) == true) {
            daysOff++;
          }

          // Tính số lần nghỉ không phép (nếu có)
          if ((schedule['is_unauthorized_absence'] ?? false) == true) {
            unauthorizedAbsence++;
          }
        }

        // Tính tổng lương
        int totalWage = workingHours * 20000 - penalty;

        payrollList.add({
          'name': fullName,
          'id': employeeId.toString(),
          'workingHours': workingHours,
          'lateHours': lateHours,
          'daysOff': daysOff,
          'unauthorizedAbsence': unauthorizedAbsence,
          'penalty': penalty,
          'totalWage': totalWage,
        });
      }

      setState(() {
        payrollData = payrollList;  // Cập nhật dữ liệu bảng lương
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu bảng lương: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lọc dữ liệu bảng lương theo tìm kiếm
    List<Map<String, dynamic>> filteredPayrollData = payrollData
        .where((item) => item['name']
            .toString()
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng lương nhân sự'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearchVisible = !isSearchVisible;  // Hiển thị thanh tìm kiếm
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isSearchVisible) 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController, 
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredPayrollData.length,
              itemBuilder: (context, index) {
                final item = filteredPayrollData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('ID: ${item['id']}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Giờ làm việc:'),
                            Text('${item['workingHours']}h'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Số giờ làm muộn:'),
                            Text('${item['lateHours']}h'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nghỉ có phép:'),
                            Text('${item['daysOff']} ngày'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nghỉ không phép:'),
                            Text('${item['unauthorizedAbsence']} lần'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tiền phạt:'),
                            Text(
                              NumberFormat.currency(locale: "vi_VN", symbol: "đ")
                                  .format(item['penalty']),
                            ),
                          ],
                        ),
                        const Divider(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Tổng lương: ${NumberFormat.currency(locale: "vi_VN", symbol: "đ").format(item['totalWage'])}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
