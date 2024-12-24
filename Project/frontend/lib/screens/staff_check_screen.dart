import 'package:flutter/material.dart';
import 'package:app/controllers/staff_check_controller.dart';

class StaffCheckApp extends StatelessWidget {
  const StaffCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Điểm danh nhân viên',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StaffCheckScreen(),
    );
  }
}

class StaffCheckScreen extends StatefulWidget {
  const StaffCheckScreen({super.key});

  @override
  State<StaffCheckScreen> createState() => _StaffCheckScreenState();
}

class _StaffCheckScreenState extends State<StaffCheckScreen> {
  late StaffCheckAppController _controller;
  List<Map<String, dynamic>> employees = [];
  List<bool?> attendanceStatus = [];
  String _searchQuery = '';
  String _selectedShift = 'ca sáng'; // Dropdown giá trị mặc định
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = StaffCheckAppController();

    // Gọi API để lấy danh sách nhân viên theo ngày hiện tại và ca sáng
    _fetchFilteredEmployees(DateTime.now(), _selectedShift);
  }

  Future<void> _fetchFilteredEmployees(DateTime date, String shiftType) async {
    setState(() => _isLoading = true);
    try {
      // Gọi API qua controller
      final data = await _controller.fetchFilteredEmployees(
        selectedDate: date,
        shiftType: shiftType,
      );

      // Cập nhật danh sách nhân viên và trạng thái điểm danh
      setState(() {
        employees = data;
        attendanceStatus = List.filled(employees.length, null);
      });

      print("Filtered Employees: $employees");
    } catch (e) {
      print('Error fetching filtered employees: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải danh sách nhân viên')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _saveAttendance() {
    List<String> attendanceDetails = [];
    for (int i = 0; i < employees.length; i++) {
      String attendance = attendanceStatus[i] == true
          ? "Có"
          : attendanceStatus[i] == false
              ? "Muộn"
              : "Chưa điểm danh";
      attendanceDetails.add("${employees[i]['full_name']}: $attendance");
    }

    String resultMessage = attendanceDetails.isNotEmpty
        ? "Điểm danh đã được lưu thành công!\n\n${attendanceDetails.join('\n')}"
        : "Không có thay đổi trong điểm danh.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now(); // Thời gian hiện tại
    String formattedDate = "${now.day}/${now.month}/${now.year}"; // Định dạng ngày tháng năm

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Điểm danh nhân viên')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    List<Map<String, dynamic>> filteredEmployees = employees
        .where((employee) => employee['full_name']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Điểm danh nhân viên',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedShift,
                  underline: Container(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedShift = newValue!;
                    });
                    _fetchFilteredEmployees(DateTime.now(), _selectedShift);
                  },
                  items: <String>['ca sáng', 'ca tối']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

              ],
            ),
            Text(
              "Tổng số nhân viên: ${filteredEmployees.length}",
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nhân viên...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: employees.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final employee = employees[index];
                return ListTile(
                  title: Text(employee['full_name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            int originalIndex = employees.indexOf(employee);
                            attendanceStatus[originalIndex] =
                                attendanceStatus[originalIndex] == true
                                    ? null
                                    : true;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              attendanceStatus[employees.indexOf(employee)] == true
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: attendanceStatus[employees.indexOf(employee)] == true
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            const Text('Có'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            int originalIndex = employees.indexOf(employee);
                            attendanceStatus[originalIndex] =
                                attendanceStatus[originalIndex] == false
                                    ? null
                                    : false;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              attendanceStatus[employees.indexOf(employee)] == false
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: attendanceStatus[employees.indexOf(employee)] == false
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            const Text('Muộn'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 45,
          width: 30,
          child: FloatingActionButton.extended(
            onPressed: _saveAttendance,
            label: const Text(
              'Lưu',
              style: TextStyle(fontSize: 14),
            ),
            icon: const Icon(
              Icons.save,
              size: 18,
            ),
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
