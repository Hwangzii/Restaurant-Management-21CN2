import 'package:app/controllers/shift_registration_controller.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ShiftRegistrationApp());
}

class ShiftRegistrationApp extends StatelessWidget {
  const ShiftRegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đăng ký ca làm',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const ShiftRegistrationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShiftRegistrationScreen extends StatefulWidget {
  const ShiftRegistrationScreen({super.key});

  @override
  State<ShiftRegistrationScreen> createState() =>
      _ShiftRegistrationScreenState();
}

class _ShiftRegistrationScreenState extends State<ShiftRegistrationScreen> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int? expandedIndex;

  // Lưu trữ trạng thái của từng ca làm cho mỗi nhân viên
  final Map<int, List<String>> selectedStatus = {};

  List<Map<String, dynamic>> employeeList = []; // Danh sách nhân viên từ API
  final Map<int, List<bool>> shiftSelections = {}; // Chọn ca làm

  @override
  void initState() {
    super.initState();
    _fetchEmployees(); // Gọi hàm lấy danh sách nhân viên
  }

  // Hàm gọi API từ controller
  Future<void> _fetchEmployees() async {
    try {
      List<Map<String, dynamic>> data =
          await ShiftRegistrationController.fetchEmployees();
      setState(() {
        employeeList = data;
        for (int i = 0; i < employeeList.length; i++) {
          shiftSelections[i] =
              List<bool>.filled(14, false); // 7 ca sáng, 7 ca tối
        }
      });
    } catch (e) {
      print("Error fetching employee list: $e");
    }
  }

  List<Map<String, dynamic>> prepareShiftsToSave(
      DateTime startDate,
      Map<int, List<bool>> shiftSelections,
      List<Map<String, dynamic>> employeeList) {
    List<Map<String, dynamic>> shiftsToSave = [];

    for (int index = 0; index < employeeList.length; index++) {
      for (int day = 0; day < 7; day++) {
        // Thêm ca sáng
        if (shiftSelections[index]![day]) {
          shiftsToSave.add({
            "work_date": startDate
                .add(Duration(days: day))
                .toIso8601String()
                .split('T')[0],
            "shift_type": "sáng",
            "shift_start": "09:00:00", // Giả định thời gian ca sáng
            "shift_end": "14:00:00", // Giả định thời gian ca sáng
            "employee": employeeList[index]['employees_id'],
            "status": selectedStatus[index]?[day] ?? "vắng", // Mặc định "vắng"
          });
        }
        // Thêm ca tối
        if (shiftSelections[index]![day + 7]) {
          shiftsToSave.add({
            "work_date": startDate
                .add(Duration(days: day))
                .toIso8601String()
                .split('T')[0],
            "shift_type": "tối",
            "shift_start": "17:00:00", // Giả định thời gian ca tối
            "shift_end": "22:00:00", // Giả định thời gian ca tối
            "employee": employeeList[index]['employees_id'],
            "status": selectedStatus[index]?[day] ?? "vắng", // Mặc định "vắng"
          });
        }
      }
    }

    return shiftsToSave;
  }

  void saveShifts() async {
    if (selectedStartDate != null) {
      // Chuẩn bị danh sách ca làm để gửi
      List<Map<String, dynamic>> shiftsToSave = prepareShiftsToSave(
          selectedStartDate!, shiftSelections, employeeList);

      try {
        // Gửi danh sách ca làm lên API
        ApiService apiService = ApiService();
        await apiService.saveWorkSchedules(shiftsToSave);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu ca làm thành công!')),
        );
      } catch (e) {
        print("Error saving shifts: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi lưu ca làm!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khoảng ngày hợp lệ!')),
      );
    }
  }

  // Hàm mở DateRangePicker tùy chỉnh
  Future<void> _showCustomDatePicker(BuildContext context) async {
    DateTime tempStartDate = DateTime.now();
    DateTime tempEndDate = tempStartDate.add(const Duration(days: 6));

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Chọn khoảng thời gian'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Ngày bắt đầu'),
                    trailing: Text(
                        "${tempStartDate.day}/${tempStartDate.month}/${tempStartDate.year}"),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempStartDate,
                        firstDate: DateTime(2023, 1),
                        lastDate: DateTime(2025, 12),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempStartDate = picked;
                          tempEndDate = picked.add(const Duration(days: 6));
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Ngày kết thúc'),
                    trailing: Text(
                        "${tempEndDate.day}/${tempEndDate.month}/${tempEndDate.year}"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (tempEndDate.difference(tempStartDate).inDays == 6) {
                        setState(() {
                          selectedStartDate = tempStartDate;
                          selectedEndDate = tempEndDate;
                        });
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Vui lòng chọn khoảng thời gian đúng 7 ngày!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Chọn'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Đăng ký ca làm'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Ô chọn ngày
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => _showCustomDatePicker(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFF4F3F8),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedStartDate != null
                          ? "${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year} - "
                              "${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}"
                          : "Chọn khoảng ngày",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFF45211),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Danh sách nhân viên
          Expanded(
            child: employeeList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: employeeList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(employeeList[index]['full_name']),
                            trailing: AnimatedRotation(
                              duration: const Duration(milliseconds: 300),
                              turns: expandedIndex == index
                                  ? 0.25
                                  : 0.0, // 0.5 là quay xuống
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                expandedIndex =
                                    expandedIndex == index ? null : index;
                              });
                            },
                          ),
                          if (expandedIndex == index)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ca sáng',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      7,
                                      (dayIndex) => Transform.scale(
                                        scale: 1.5, // Tăng kích thước checkbox
                                        child: Theme(
                                          data: ThemeData(
                                            checkboxTheme: CheckboxThemeData(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20), // Bo tròn
                                              ),
                                              fillColor: MaterialStateProperty
                                                  .resolveWith(
                                                (states) => states.contains(
                                                        MaterialState.selected)
                                                    ? Color(
                                                        0xFFF45211) // Màu cam khi được chọn
                                                    : Colors
                                                        .white, // Màu xám khi không chọn
                                              ),
                                            ),
                                          ),
                                          child: Checkbox(
                                            value: shiftSelections[index]![
                                                dayIndex],
                                            onChanged: (val) {
                                              setState(() {
                                                shiftSelections[index]![
                                                    dayIndex] = val!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Ca tối',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      7,
                                      (dayIndex) => Transform.scale(
                                        scale: 1.5, // Tăng kích thước checkbox
                                        child: Theme(
                                          data: ThemeData(
                                            checkboxTheme: CheckboxThemeData(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20), // Bo tròn
                                              ),
                                              fillColor: MaterialStateProperty
                                                  .resolveWith(
                                                (states) => states.contains(
                                                        MaterialState.selected)
                                                    ? Color(
                                                        0xFFF45211) // Màu cam khi được chọn
                                                    : Colors
                                                        .white, // Màu xám khi không chọn
                                              ),
                                            ),
                                          ),
                                          child: Checkbox(
                                            value: shiftSelections[index]![
                                                dayIndex + 7],
                                            onChanged: (val) {
                                              setState(() {
                                                shiftSelections[index]![
                                                    dayIndex + 7] = val!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF45211)),
            onPressed: () {
              saveShifts();
            },
            child: const Text(
              'Lưu',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
