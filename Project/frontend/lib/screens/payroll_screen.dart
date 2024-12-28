import 'package:app/controllers/salaris_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayrollScreen extends StatefulWidget {
  @override
  _PayrollScreenState createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  DateTime? selectedDate;
  bool isLoading = false;
  TextEditingController searchController =
      TextEditingController(); // Controller cho tìm kiếm
  bool isSearchVisible =
      false; // Biến để điều khiển việc hiển thị thanh tìm kiếm
  List<Map<String, dynamic>> salaries = [];
  final SalariesController salariesController = SalariesController();

  @override
  void initState() {
    super.initState();
    _fetchSalaries();
  }

  Future<void> _fetchSalaries() async {
    setState(() {
      isLoading = true;
    });
    try {
      await salariesController.fetchSalaries();
      setState(() {
        salaries = salariesController.salaries;
      });
    } catch (e) {
      print("Error fetching salaries: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Thanh toán tất cả các bản ghi lương
  Future<void> _payAllSalaries() async {
    setState(() {
      isLoading = true;
    });
    try {
      final invoices = await salariesController.payAllSalaries();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Đã thanh toán ${invoices.length} bản ghi lương!')),
      );
      _fetchSalaries(); // Cập nhật lại danh sách sau khi thanh toán
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thanh toán lương: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dữ liệu bảng lương đã được lọc theo truy vấn tìm kiếm
    List<Map<String, dynamic>> filteredPayrollData = salaries
        .where((item) => item['employee_name']
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
                isSearchVisible =
                    !isSearchVisible; // Chuyển đổi hiển thị thanh tìm kiếm
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Phần thanh tìm kiếm
          if (isSearchVisible)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          searchController, // Gán controller cho thanh tìm kiếm
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(
                            () {}); // Làm mới giao diện khi thay đổi truy vấn tìm kiếm
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Phần chọn ngày
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Phần danh sách bảng lương
          Expanded(
            child: ListView.builder(
              itemCount: filteredPayrollData.length,
              itemBuilder: (context, index) {
                final item = filteredPayrollData[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['employee_name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Giờ làm việc:'),
                            Text('${item['total_timework']}h'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Số lần đi muộn:'),
                            Text('${item['total_timegolate']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nghỉ có phép:'),
                            Text('${item['total_Permitted_leave']} ngày'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nghỉ không phép:'),
                            Text('${item['total_absent']} ngày'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng lương:'),
                            Text(
                              NumberFormat.currency(
                                      locale: "vi_VN", symbol: "đ")
                                  .format(item['salary']),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tiền bị phạt:'),
                            Text(
                              NumberFormat.currency(
                                      locale: "vi_VN", symbol: "đ")
                                  .format(item['penalty']),
                            ),
                          ],
                        ),
                        const Divider(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Lương thực nhận: ${NumberFormat.currency(locale: "vi_VN", symbol: "đ").format(item['final_salary'])}',
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

          // Nút thanh toán
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _payAllSalaries,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color.fromARGB(255, 224, 93, 6),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Thanh toán lương',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
