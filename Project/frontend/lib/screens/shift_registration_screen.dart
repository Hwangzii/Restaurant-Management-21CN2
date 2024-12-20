import 'package:app/controllers/shift_registration_controller.dart';
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
          shiftSelections[i] = List<bool>.filled(14, false); // 7 ca sáng, 7 ca tối
        }
      });
    } catch (e) {
      print("Error fetching employee list: $e");
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
      appBar: AppBar(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
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
                    const Icon(Icons.calendar_today),
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
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              setState(() {
                                expandedIndex =
                                    expandedIndex == index ? null : index;
                              });
                            },
                          ),
                          if (expandedIndex == index)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ca sáng'),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      7,
                                      (dayIndex) => Checkbox(
                                        value: shiftSelections[index]![dayIndex],
                                        onChanged: (val) {
                                          setState(() {
                                            shiftSelections[index]![dayIndex] =
                                                val!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const Text('Ca tối'),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      7,
                                      (dayIndex) => Checkbox(
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              print("Ngày đã chọn: $selectedStartDate - $selectedEndDate");
              print(shiftSelections);
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
