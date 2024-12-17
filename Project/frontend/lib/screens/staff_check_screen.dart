import 'package:flutter/material.dart';

class StaffCheckApp extends StatelessWidget {
  const StaffCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Điểm danh nhân viên',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  // Danh sách tên nhân viên
  List<String> employeeNames = [
    "Nguyễn Hồng Phi",
    "Lương Ngọc Sơn",
    "Dương Nhật Đức Việt",
    "Nguyễn Đỗ Công",
    "Nguyễn Hà Thanh",
    "Nguyễn Hồng Phi",
    "Ngọc Sơn",
    "Dương Nhật Đức ",
    "Nguyễn Đỗ Công",
    "Hà Thanh",
    "Nguyễn ồng Phi",
    "Lương Ngọc Sơn",
    "Nguyễn Hồng Phi",
    "Ngọc Sơn",
    "Dương Nhật Đức ",
    "Nguyễn Đỗ Công",
    "Hà Thanh",
    "Nguyễn ồng Phi",
    "Lương Ngọc Sơn",
    "Nguyễn Hồng Phi",
    "Ngọc Sơn",
    "Dương Nhật Đức ",
    "Nguyễn Đỗ Công",
    "Hà Thanh",
    "Nguyễn ồng Phi",
    "Lương Ngọc Sơn",
  ];

  // Danh sách trạng thái điểm danh: null = chưa chọn, true = Có, false = Muộn
  late List<bool?> attendanceStatus;

  // Biến lưu giá trị tìm kiếm
  String _searchQuery = '';

  // Biến kiểm tra cuộn hết danh sách
  bool _isEndOfList = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách trạng thái điểm danh với số lượng nhân viên hiện tại
    attendanceStatus = List.filled(employeeNames.length, null);
  }

  // Hàm xử lý khi bấm nút lưu
  void _saveAttendance() {
    for (int i = 0; i < employeeNames.length; i++) {
      debugPrint(
          "${employeeNames[i]}: ${attendanceStatus[i] == true ? "Có" : attendanceStatus[i] == false ? "Muộn" : "Chưa điểm danh"}");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Điểm danh đã được lưu thành công!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách theo từ khóa tìm kiếm
    List<String> filteredNames = employeeNames
        .where((name) => name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Đảm bảo số lượng trạng thái điểm danh phù hợp với danh sách nhân viên lọc
    List<bool?> filteredAttendanceStatus = attendanceStatus
        .take(filteredNames.length)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm danh nhân viên'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
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
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification) {
            // Kiểm tra khi đã cuộn đến cuối
            if (notification.metrics.extentAfter == 0) {
              setState(() {
                _isEndOfList = true;
              });
            } else {
              setState(() {
                _isEndOfList = false;
              });
            }
          }
          return false;
        },
        child: Column(
          children: [
            // Hiển thị tổng số nhân viên sau khi lọc
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Tổng số nhân viên: ${filteredNames.length}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
            // Danh sách nhân viên và trạng thái điểm danh
            Expanded(
              child: ListView.separated(
                itemCount: filteredNames.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Color.fromARGB(255, 232, 229, 229),
                  thickness: 1,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      filteredNames[index],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: filteredAttendanceStatus[index],
                              activeColor: Colors.orange,
                              onChanged: (value) {
                                setState(() {
                                  // Cập nhật trạng thái điểm danh trong danh sách gốc
                                  attendanceStatus[employeeNames.indexOf(filteredNames[index])] = value;
                                });
                              },
                            ),
                            const Text('Có'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: false,
                              groupValue: filteredAttendanceStatus[index],
                              activeColor: Colors.grey,
                              onChanged: (value) {
                                setState(() {
                                  // Cập nhật trạng thái điểm danh trong danh sách gốc
                                  attendanceStatus[employeeNames.indexOf(filteredNames[index])] = value;
                                });
                              },
                            ),
                            const Text('Muộn'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Hiển thị nút "Lưu" chỉ khi đã cuộn hết danh sách
            if (_isEndOfList)
              Align(
                alignment: Alignment.bottomRight, // Đặt nút ở góc dưới bên phải
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.extended(
                    onPressed: _saveAttendance, // Gọi hàm lưu điểm danh
                    label: const Text('Lưu'),
                    icon: const Icon(Icons.save),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
