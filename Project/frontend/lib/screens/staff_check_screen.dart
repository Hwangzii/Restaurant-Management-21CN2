import 'package:flutter/material.dart';
import 'package:app/controllers/staff_check_controller.dart';
import 'package:intl/intl.dart';

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
  List<Map<String, dynamic>> employees = [];
  Map<int, bool?> attendanceStatus = {}; // Trạng thái có/muộn/null
  Map<int, String?> absenceReasons = {}; // Lý do nghỉ/null
  final String _searchQuery = '';
  String _selectedShift = 'ca sáng';
  bool _isLoading = false;
  DateTime? selectedDate = DateTime.now();
  bool isSaveButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _fetchFilteredEmployees(DateTime.now(), _selectedShift);
    _dateController.text = 'Chọn ngày'; // Đặt giá trị mặc định cho TextField
  }

  final TextEditingController _dateController = TextEditingController();

  Future<void> _fetchFilteredEmployees(DateTime date, String shiftType) async {
    setState(() => _isLoading = true); // Bắt đầu tải dữ liệu
    try {
      final data = await StaffCheckAppController.fetchFilteredEmployees(
        selectedDate: date,
        shiftType: shiftType,
      );
      setState(() {
        employees = data; // Cập nhật danh sách nhân viên
        // attendanceStatus.clear(); // Làm sạch trạng thái cũ
        absenceReasons.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải danh sách nhân viên')),
      );
    } finally {
      setState(() => _isLoading = false); // Kết thúc tải dữ liệu
    }
  }

  void _checkIfToday(DateTime? pickedDate) {
    if (pickedDate != null) {
      final today = DateTime.now();
      final onlyToday = DateTime(today.year, today.month, today.day);
      final onlyPickedDate =
          DateTime(pickedDate.year, pickedDate.month, pickedDate.day);

      final isToday = onlyToday == onlyPickedDate;
      if (isSaveButtonVisible != isToday) {
        setState(() {
          isSaveButtonVisible = isToday;
        });
      }
    }
  }

  void _showAbsenceReasonDialog(int index) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nhập lý do nghỉ"),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: "Nhập lý do nghỉ...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Đóng dialog ngay lập tức nếu nhấn "Hủy"
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                // Lấy lý do nghỉ
                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng nhập lý do nghỉ."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  absenceReasons[index] = reason;
                  attendanceStatus[index] = null; // Reset trạng thái khác
                });

                // Lấy employeeId và shiftType từ logic đã dùng trong `_saveAttendance`
                final employeeId = employees[index]['employees_id'];
                final shiftType = _selectedShift == 'ca sáng' ? 'sáng' : 'tối';

                // Kiểm tra employeeId và shiftType
                if (employeeId == null || employeeId is! int) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Lỗi: employeeId không hợp lệ cho nhân viên ${employees[index]['full_name']}",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Gọi API để cập nhật lý do nghỉ
                  final result = await StaffCheckAppController
                      .updatereasonStatusByEmployee(
                    employeeId,
                    shiftType,
                    reason,
                  );

                  if (result['success']) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Lý do nghỉ đã được cập nhật thành công!"),
                      ),
                    );
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Lỗi: ${result['message']}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Lỗi khi kết nối API: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                // Đóng AlertDialog sau khi mọi thứ hoàn tất
                Navigator.pop(context);
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _saveAttendance() async {
    List<String> attendanceDetails = [];
    bool isError = false;

    for (int i = 0; i < employees.length; i++) {
      String attendance;

      // Xác định trạng thái điểm danh
      if (attendanceStatus[i] == true) {
        attendance = "có"; // Có mặt
      } else if (attendanceStatus[i] == false) {
        attendance = "muộn"; // Đi muộn
      } else if (absenceReasons[i] != null) {
        attendance = "nghỉ có phép"; // Nghỉ có phép
      } else {
        attendance = "nghỉ không phép"; // Nghỉ không phép
      }

      // Lấy `employee_id` và `shiftType`
      final employeeId = employees[i]['employees_id'];
      final shiftType = _selectedShift == 'ca sáng' ? 'sáng' : 'tối';

      // Kiểm tra `employee_id` trước khi gọi API
      if (employeeId == null || employeeId is! int) {
        isError = true;
        attendanceDetails.add(
            "Lỗi kết nối: ${employees[i]['employees_id']} (employee_id không hợp lệ)");
        continue;
      }

      // Thêm chi tiết điểm danh
      attendanceDetails.add("${employees[i]['full_name']}: $attendance");

      // Gọi API qua controller
      try {
        final result = await StaffCheckAppController.updateStatusByEmployee(
          employeeId,
          shiftType,
          attendance,
        );

        if (!result['success']) {
          print(
              "Lỗi cập nhật trạng thái cho ${employees[i]['full_name']}: ${result['message']}");
        }
      } catch (e) {
        isError = true;
        attendanceDetails
            .add("Lỗi kết nối: ${employees[i]['full_name']} (${e.toString()})");
      }
    }

    // Hiển thị thông báo
    if (!isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Điểm danh đã được lưu thành công!\n\n${attendanceDetails.join('\n')}",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Một số trạng thái không được cập nhật:\n\n${attendanceDetails.join('\n')}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime dayselect = DateTime.now();

    // String formattedDate =
    //     "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

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
            const Text(
              'Điểm danh',
              style: TextStyle(color: Colors.black, fontSize: 20),
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
          // Phần chọn ngày và ca làm việc
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                          : 'Chọn ngày',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                // Phần chọn ngày
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });

                      // Gọi API để lọc nhân viên theo ngày
                      _fetchFilteredEmployees(dayselect, _selectedShift);
                      _checkIfToday(pickedDate);
                    }
                  },
                ),

                // Phần chọn ca làm việc
                DropdownButton<String>(
                  value: _selectedShift,
                  underline: Container(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedShift = newValue!;
                    });

                    // Gọi API để lọc nhân viên theo ca làm việc
                    _fetchFilteredEmployees(dayselect, _selectedShift);
                  },
                  items: <String>['ca sáng', 'ca tối']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Danh sách nhân viên
          Expanded(
            child: ListView.separated(
              itemCount: filteredEmployees.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                final originalIndex = employees.indexOf(employee);
                return ListTile(
                  title: Text(employee['full_name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            attendanceStatus[originalIndex] =
                                attendanceStatus[originalIndex] == true
                                    ? null
                                    : true;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              attendanceStatus[originalIndex] == true
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: attendanceStatus[originalIndex] == true
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            const Text('Có'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            attendanceStatus[originalIndex] =
                                attendanceStatus[originalIndex] == false
                                    ? null
                                    : false;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              attendanceStatus[originalIndex] == false
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: attendanceStatus[originalIndex] == false
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            const Text('Muộn'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (absenceReasons[originalIndex] != null) {
                              absenceReasons[originalIndex] = null;
                              attendanceStatus[originalIndex] = null;
                            } else {
                              _showAbsenceReasonDialog(originalIndex);
                            }
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              absenceReasons[originalIndex] != null
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: absenceReasons[originalIndex] != null
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            const Text('Nghỉ'),
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
      bottomNavigationBar: isSaveButtonVisible
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 45,
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
                  backgroundColor: const Color(0xFFFF8A00),
                ),
              ),
            )
          : null,
    );
  }
}
