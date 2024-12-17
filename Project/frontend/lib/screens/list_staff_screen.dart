import 'package:app/screens/add_staff_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class ListStaffScreen extends StatefulWidget {
  const ListStaffScreen({Key? key}) : super(key: key);

  @override
  State<ListStaffScreen> createState() => _ListStaffScreenState();
}

class _ListStaffScreenState extends State<ListStaffScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _futureEmployees;

  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureEmployees = _apiService.fetchEmployees();
    _futureEmployees.then((data) {
      setState(() {
        employees = data;
        filteredEmployees = data; // Hiển thị ban đầu
      });
    });
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredEmployees = employees; // Reset danh sách khi không có input
      });
      return;
    }

    setState(() {
      filteredEmployees = employees.where((employee) {
        final name = employee['full_name']?.toLowerCase() ?? '';
        final id = employee['employees_id']?.toString() ?? '';
        final statusWork = employee['status_work'] == true ? 'đang làm việc' : 'vắng';
        final searchLower = query.toLowerCase();

        return name.contains(searchLower) ||
              id.contains(searchLower) ||
              statusWork.contains(searchLower);
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Danh sách nhân sự',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: const Icon(Icons.menu, color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Chuyển đến màn hình AddStaffScreen khi nhấn vào Icon
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddStaffScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],

      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureEmployees,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có nhân viên nào.'));
          }

          return Column(
            children: [
              // Ô tìm kiếm
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterSearchResults,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                searchController.clear(); // Xóa dữ liệu nhập
                                filterSearchResults(''); // Cập nhật danh sách về trạng thái ban đầu
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Danh sách nhân viên
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredEmployees.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];
                    final isAbsent = employee['status_work'] == "inactive";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isAbsent ? Colors.red : Colors.green,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        employee['full_name'] ?? 'Không rõ tên',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Id: ${employee['employees_id'] ?? ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        employee['status_work'] == true ? 'Đang làm việc' : 'Vắng',
                        style: TextStyle(
                          color: employee['status_work'] == true ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
