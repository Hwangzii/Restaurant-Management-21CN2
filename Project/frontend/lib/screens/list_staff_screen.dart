import 'package:flutter/material.dart';
import 'package:app/controllers/list_staff_controller.dart';
import 'package:app/screens/add_staff_screen.dart';

class ListStaffScreen extends StatefulWidget {
  const ListStaffScreen({Key? key}) : super(key: key);

  @override
  State<ListStaffScreen> createState() => _ListStaffScreenState();
}

class _ListStaffScreenState extends State<ListStaffScreen> {
  late Future<List<Map<String, dynamic>>> _futureEmployees;
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  void _loadEmployees() {
    _futureEmployees = ListStaffController.fetchStaffList();
    _futureEmployees.then((data) {
      setState(() {
        employees = data;
        filteredEmployees = data;
      });
    });
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredEmployees = employees.where((employee) {
        final name = employee['full_name']?.toLowerCase() ?? '';
        final id = employee['employees_id']?.toString() ?? '';
        return name.contains(query.toLowerCase()) ||
            id.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showOptionsDialog(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Tùy chọn cho ${employee['full_name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Xem thông tin"),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddStaffScreen(employee: employee),
                    ),
                  );
                  if (result == true) _loadEmployees();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Xóa nhân viên"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(employee['employees_id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(int employeeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa nhân viên này không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                bool success =
                    await ListStaffController.deleteStaff(employeeId);
                if (success) _loadEmployees();
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Danh sách nhân sự"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddStaffScreen()),
              );

              if (result == true)
                _loadEmployees(); // Làm mới danh sách khi có thay đổi
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterSearchResults,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black, // Chỉnh màu icon search
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          filterSearchResults('');
                        },
                      )
                    : null,
                hintText: "Tìm kiếm",
                hintStyle:
                    TextStyle(color: Color(0xFF808B96)), // Chỉnh màu hintText
                filled: true,
                fillColor:
                    Color(0xFFF4F3F8), // Màu nền của TextField (tuỳ chỉnh)
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15), // Bo góc cho TextField
                  borderSide: BorderSide.none, // Không có viền
                ), // Bỏ viền
                contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16), // Điều chỉnh padding cho TextField
              ),
              style: TextStyle(
                  color: Colors.black), // Chỉnh màu chữ trong TextField
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureEmployees,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                }
                return ListView.builder(
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];
                    return Dismissible(
                      key: Key(employee['employees_id'].toString()),
                      direction:
                          DismissDirection.endToStart, // Vuốt sang phải để xóa
                      background: Container(
                        color: Colors.red, // Màu nền khi vuốt
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Image.asset(
                          'assets/delete.png', // Đường dẫn đến hình ảnh
                          height: 24,
                          width: 24,
                          color: Colors.white, // Tùy chọn chỉnh màu nếu cần
                        ),
                      ),
                      onDismissed: (direction) async {
                        bool success = await ListStaffController.deleteStaff(
                            employee['employees_id']);
                        if (success) {
                          setState(() {
                            filteredEmployees
                                .removeAt(index); // Xóa item khỏi danh sách
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "${employee['full_name']} đã được xóa")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Xóa không thành công")),
                          );
                        }
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Color(0xFFE3E4E8), // Màu nền của CircleAvatar
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF6F7376), // Màu icon
                          ),
                        ),
                        title: Text(employee['full_name']),
                        subtitle: Text("Id: ${employee['employees_id']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          color: Color(0xFFEF4D2D), // Màu của biểu tượng
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddStaffScreen(employee: employee),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
