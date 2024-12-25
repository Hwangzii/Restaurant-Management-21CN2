import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayrollScreen extends StatefulWidget {
  @override
  _PayrollScreenState createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  DateTime? selectedDate;
  TextEditingController searchController = TextEditingController(); // Controller cho tìm kiếm
  bool isSearchVisible = false; // Biến để điều khiển việc hiển thị thanh tìm kiếm
  List<Map<String, dynamic>> payrollData = [
    {
      'name': 'Nguyen Hoang Phi',
      'id': '2155010196',
      'workingHours': 220,
      'lateHours': 1,
      'daysOff': 3,
      'unauthorizedAbsence': 0,
      'penalty': 60000,
      'totalWage': 4340000,
    },
    {
      'name': 'Tran Thi Lan',
      'id': '2155010197',
      'workingHours': 180,
      'lateHours': 2,
      'daysOff': 1,
      'unauthorizedAbsence': 1,
      'penalty': 50000,
      'totalWage': 3700000,
    },
    {
        'name': 'Tran Van Binh',
        'id': '2155010197',
        'workingHours': 210,
        'lateHours': 2,
        'daysOff': 2,
        'unauthorizedAbsence': 1,
        'penalty': 80000,
        'totalWage': 4210000,
      },
      {
        'name': 'Le Thi Hoa',
        'id': '2155010198',
        'workingHours': 230,
        'lateHours': 0,
        'daysOff': 1,
        'unauthorizedAbsence': 0,
        'penalty': 0,
        'totalWage': 4600000,
      },
      {
        'name': 'Pham Minh Tu',
        'id': '2155010199',
        'workingHours': 200,
        'lateHours': 3,
        'daysOff': 4,
        'unauthorizedAbsence': 2,
        'penalty': 120000,
        'totalWage': 4000000,
      },
      {
        'name': 'Vo Thi Mai',
        'id': '2155010200',
        'workingHours': 240,
        'lateHours': 0,
        'daysOff': 0,
        'unauthorizedAbsence': 0,
        'penalty': 0,
        'totalWage': 4800000,
      },
      {
        'name': 'Dang Huu Nghia',
        'id': '2155010201',
        'workingHours': 190,
        'lateHours': 4,
        'daysOff': 5,
        'unauthorizedAbsence': 1,
        'penalty': 150000,
        'totalWage': 3800000,
      },
      {
        'name': 'Hoang Thi Ly',
        'id': '2155010202',
        'workingHours': 220,
        'lateHours': 1,
        'daysOff': 2,
        'unauthorizedAbsence': 0,
        'penalty': 60000,
        'totalWage': 4340000,
      },
      {
        'name': 'Nguyen Van Hung',
        'id': '2155010203',
        'workingHours': 205,
        'lateHours': 2,
        'daysOff': 3,
        'unauthorizedAbsence': 1,
        'penalty': 70000,
        'totalWage': 4100000,
      },
      {
        'name': 'Le Van Cuong',
        'id': '2155010204',
        'workingHours': 210,
        'lateHours': 0,
        'daysOff': 2,
        'unauthorizedAbsence': 0,
        'penalty': 50000,
        'totalWage': 4200000,
      },
      {
        'name': 'Nguyen Thi Dung',
        'id': '2155010205',
        'workingHours': 200,
        'lateHours': 3,
        'daysOff': 3,
        'unauthorizedAbsence': 1,
        'penalty': 100000,
        'totalWage': 4000000,
      },
      {
        'name': 'Pham Van Dat',
        'id': '2155010206',
        'workingHours': 215,
        'lateHours': 2,
        'daysOff': 1,
        'unauthorizedAbsence': 0,
        'penalty': 40000,
        'totalWage': 4300000,
      },
      {
        'name': 'Do Thi Huong',
        'id': '2155010207',
        'workingHours': 220,
        'lateHours': 1,
        'daysOff': 2,
        'unauthorizedAbsence': 1,
        'penalty': 60000,
        'totalWage': 4340000,
      },
      {
        'name': 'Vu Thi Mai',
        'id': '2155010208',
        'workingHours': 200,
        'lateHours': 2,
        'daysOff': 4,
        'unauthorizedAbsence': 1,
        'penalty': 90000,
        'totalWage': 3950000,
      },
      {
        'name': 'Tran Van Hieu',
        'id': '2155010209',
        'workingHours': 230,
        'lateHours': 0,
        'daysOff': 1,
        'unauthorizedAbsence': 0,
        'penalty': 0,
        'totalWage': 4600000,
      },
      {
        'name': 'Nguyen Thi Lan',
        'id': '2155010210',
        'workingHours': 215,
        'lateHours': 2,
        'daysOff': 3,
        'unauthorizedAbsence': 0,
        'penalty': 50000,
        'totalWage': 4250000,
      },
      {
        'name': 'Tran Thi Bich',
        'id': '2155010211',
        'workingHours': 220,
        'lateHours': 1,
        'daysOff': 1,
        'unauthorizedAbsence': 0,
        'penalty': 30000,
        'totalWage': 4370000,
      },
      {
        'name': 'Do Van Quyen',
        'id': '2155010212',
        'workingHours': 190,
        'lateHours': 3,
        'daysOff': 5,
        'unauthorizedAbsence': 2,
        'penalty': 120000,
        'totalWage': 3800000,
      },
      {
        'name': 'Nguyen Minh Ha',
        'id': '2155010213',
        'workingHours': 240,
        'lateHours': 0,
        'daysOff': 0,
        'unauthorizedAbsence': 0,
        'penalty': 0,
        'totalWage': 4800000,
      },
      {
        'name': 'Vo Van Phat',
        'id': '2155010214',
        'workingHours': 200,
        'lateHours': 2,
        'daysOff': 2,
        'unauthorizedAbsence': 1,
        'penalty': 70000,
        'totalWage': 4050000,
      },
      {
        'name': 'Le Thi Quyen',
        'id': '2155010215',
        'workingHours': 210,
        'lateHours': 1,
        'daysOff': 2,
        'unauthorizedAbsence': 0,
        'penalty': 50000,
        'totalWage': 4200000,
      },


  ];

  @override
  Widget build(BuildContext context) {
    // Dữ liệu bảng lương đã được lọc theo truy vấn tìm kiếm
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
                isSearchVisible = !isSearchVisible; // Chuyển đổi hiển thị thanh tìm kiếm
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
                      controller: searchController, // Gán controller cho thanh tìm kiếm
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {}); // Làm mới giao diện khi thay đổi truy vấn tìm kiếm
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
                            Text('${item['unauthorizedAbsence']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tiền bị phạt:'),
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

          // Nút thanh toán
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
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
