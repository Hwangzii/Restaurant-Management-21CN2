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
  List<Map<String, dynamic>> employees = [];
  List<bool?> attendanceStatus = [];
  List<String?> absenceReasons = [];
  String _searchQuery = '';
  String _selectedShift = 'ca sáng';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFilteredEmployees(DateTime.now(), _selectedShift);
  }

  Future<void> _fetchFilteredEmployees(DateTime date, String shiftType) async {
    setState(() => _isLoading = true);
    try {
      final data = await StaffCheckAppController.fetchFilteredEmployees(
        selectedDate: date,
        shiftType: shiftType,
      );

      setState(() {
        employees = data;
        attendanceStatus = List.filled(employees.length, null);
        absenceReasons = List.filled(employees.length, null);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải danh sách nhân viên')),
      );
    } finally {
      setState(() => _isLoading = false);
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
                Navigator.pop(context);
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  absenceReasons[index] = reasonController.text;
                  attendanceStatus[index] = null; // Reset trạng thái khác
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lưu lý do nghỉ thành công!")),
                );
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _saveAttendance() {
    List<String> attendanceDetails = [];
    for (int i = 0; i < employees.length; i++) {
      String attendance = attendanceStatus[i] == true
          ? "Có"
          : attendanceStatus[i] == false
              ? "Muộn"
              : absenceReasons[i] != null
                  ? "Nghỉ: ${absenceReasons[i]}"
                  : "Chưa điểm danh";
      attendanceDetails.add("${employees[i]['full_name']}: $attendance");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Điểm danh đã được lưu thành công!\n\n${attendanceDetails.join('\n')}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}/${now.month}/${now.year}";

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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40,
          child: FloatingActionButton.extended(
            onPressed: _saveAttendance,
            label: const Text(
              'Lưu',
              style: TextStyle(fontSize: 14),
            ),
            backgroundColor: Color(0xFFFF8A00),
          ),
        ),
      ),
    );
  }
}
