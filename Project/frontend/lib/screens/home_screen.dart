import 'package:app/controllers/invoice_controller.dart';
import 'package:app/models/user.dart';
import 'package:app/screens/invoice_screen.dart';
import 'package:app/screens/menu_options.dart';
import 'package:app/screens/order_food_screen.dart';
import 'package:app/screens/tables_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:app/controllers/notification_controller.dart';
import 'package:intl/intl.dart'; // Import controller

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();

  String formatDate(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(parsedDate);
    } catch (e) {
      return dateString; // Trả về giá trị gốc nếu không thể định dạng
    }
  }
}

// Biến màu chung
const Color commonIconBackgroundColor = Color(0xFFF5F5F5);

// hàm xử lý số liệu
String formatNumberShort(double value) {
  // Thêm dấu + đằng trước giá trị
  String sign = value >= 0 ? '+' : ''; // Nếu giá trị lớn hơn 0 thì thêm dấu '+'

  if (value >= 1e9) {
    // Trường hợp lớn hơn hoặc bằng 1 tỉ
    return '$sign${(value / 1e9).toStringAsFixed(1)} tỉ';
  } else if (value >= 1e6) {
    // Trường hợp lớn hơn hoặc bằng 1 triệu
    return '$sign${(value / 1e6).toStringAsFixed(1)} tr';
  } else {
    // Trường hợp nhỏ hơn 1 triệu (nếu cần xử lý)
    return '$sign${value.toStringAsFixed(0)}';
  }
}

// hàm xử lý số liệu
String formatNumberShort1(double value) {
  // Thêm dấu + đằng trước giá trị
  String sign = value >= 0 ? '-' : ''; // Nếu giá trị lớn hơn 0 thì thêm dấu '+'

  if (value >= 1e9) {
    // Trường hợp lớn hơn hoặc bằng 1 tỉ
    return '$sign${(value / 1e9).toStringAsFixed(1)} tỉ';
  } else if (value >= 1e6) {
    // Trường hợp lớn hơn hoặc bằng 1 triệu
    return '$sign${(value / 1e6).toStringAsFixed(1)} tr';
  } else {
    // Trường hợp nhỏ hơn 1 triệu (nếu cần xử lý)
    return '$sign${value.toStringAsFixed(0)}';
  }
}

// Danh sách dữ liệu icon
final List<Map<String, dynamic>> iconsData = [
  {
    'imagePath': 'assets/food.png',
    'name': 'Món ăn',
    'color': commonIconBackgroundColor,
    'route': '/FoodScreen'
  },
  {
    'imagePath': 'assets/order.png',
    'name': 'Gọi món',
    'color': commonIconBackgroundColor,
    'route': '/TablesScreen'
  },
  {
    'imagePath': 'assets/staff_check.png',
    'name': 'Điểm danh',
    'color': commonIconBackgroundColor,
    'route': '/StaffCheckScreen'
  },
  {
    'imagePath': 'assets/clients.png',
    'name': 'khách hàng',
    'color': commonIconBackgroundColor,
    'route': '/ClientsScreen'
  },
];

String _getCurrentDate() {
  final now = DateTime.now();
  final weekDays = [
    'Chủ nhật',
    'Thứ hai',
    'Thứ ba',
    'Thứ tư',
    'Thứ năm',
    'Thứ sáu',
    'Thứ bảy'
  ];
  final currentWeekDay = weekDays[now.weekday % 7];
  return '$currentWeekDay, ${now.day}/${now.month}/${now.year}';
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationController _notificationController =
      NotificationController(); // Khởi tạo controller

  final ApiService _apiService = ApiService();
  final InvoiceController invoiceController = InvoiceController();
  List<Map<String, dynamic>> invoices = [];
  double totalRevenue = 0.0;
  double totalRevenue1 = 0.0;
  double totalRevenue2 = 0.0;
  double totalRevenue3 = 0.0;
  int totalRevenue4 = 0;
  int totalRevenue5 = 0;
  bool isLoading = true;
  late Future<List<Map<String, dynamic>>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    fetchTotalRevenue();
    fetchTotalRevenue1(); // Gọi hàm để lấy dữ liệu tổng doanh thu
    fetchTotalRevenue2();
    fetchTotalRevenue3();
    fetchTotalRevenue4();
    fetchTotalRevenue5();
    _invoicesFuture = _fetchInvoices();
  }

  Future<List<Map<String, dynamic>>> _fetchInvoices() async {
    try {
      await invoiceController.fetchInvoices();
      List<Map<String, dynamic>> invoices = invoiceController.invoices;

      // Sắp xếp danh sách hóa đơn theo `created_at` giảm dần (mới nhất trước)
      invoices.sort((a, b) {
        final dateA = DateTime.parse(a['created_at']);
        final dateB = DateTime.parse(b['created_at']);
        return dateB.compareTo(dateA); // Sắp xếp giảm dần
      });

      // Chỉ lấy 4 bản ghi đầu tiên (4 hóa đơn mới nhất)
      return invoices.take(4).toList();
    } catch (e) {
      print("Error fetching invoices: $e");
      throw Exception("Failed to fetch invoices");
    }
  }

  String formatCurrency(String amount) {
    final number =
        double.tryParse(amount.replaceAll(',', '').replaceAll('đ', '')) ?? 0;
    final format = NumberFormat.simpleCurrency(locale: 'vi_VN');
    return format.format(number);
  }

  String formatDate(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(parsedDate);
    } catch (e) {
      return dateString; // Trả về giá trị gốc nếu không thể định dạng
    }
  }

  void fetchTotalRevenue() async {
    try {
      double revenue = await _apiService.fetchTotalRevenue();
      setState(() {
        totalRevenue = revenue;
        isLoading = false; // Kết thúc loading
      });
    } catch (e) {
      print('Error fetching total revenue: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchTotalRevenue1() async {
    try {
      double revenue = await _apiService.fetchFinancialSummary();
      setState(() {
        totalRevenue1 = revenue;
        isLoading = false; // Kết thúc loading
      });
    } catch (e) {
      print('Error fetching total revenue: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchTotalRevenue2() async {
    try {
      double revenue = await _apiService.fetchTotalCost();
      setState(() {
        totalRevenue2 = revenue;
        isLoading = false; // Kết thúc loading
      });
    } catch (e) {
      print('Error fetching total revenue: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchTotalRevenue3() async {
    try {
      double revenue = await _apiService.fetchIncomeGrowthPercentage();
      setState(() {
        totalRevenue3 = revenue;
        isLoading = false; // Kết thúc loading
      });
    } catch (e) {
      print('Error fetching total revenue: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchTotalRevenue4() async {
    try {
      int revenue = await _apiService.countType1Records();
      setState(() {
        totalRevenue4 = revenue;
        isLoading = false; // Kết thúc loading
      });
    } catch (e) {
      print('Error fetching total revenue: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchTotalRevenue5() async {
    try {
      int revenue = await _apiService.countActiveTables();
      setState(() {
        totalRevenue5 = revenue;
        isLoading = false; // Kết thúc loading
      });
    } catch (e) {
      print('Error fetching total revenue: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình
    double screenWidth = MediaQuery.of(context).size.width;

    // Chiều rộng của container đầu tiên sẽ bằng với chiều rộng của 4 ô vuông trong GridView
    double containerWidth =
        (screenWidth - 3 * 10) / 4; // Trừ đi khoảng cách giữa các ô vuông

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // ẩn nút back
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Avatar với sự kiện chuyển form
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MenuOptions(
                            user: widget.user,
                          )),
                );
              },
              child: CircleAvatar(
                radius: 18, // Kích thước avatar
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
            ),

            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.user.name}', // Hiển thị username từ API
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getCurrentDate(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            // Hàng đầu tiên: text "Tổng doanh thu (VNĐ)" và icon con mắt (eye)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Số dư (VNĐ)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF929292),
                        ),
                      ),
                      SizedBox(width: 15),
                      Icon(
                        Icons.remove_red_eye,
                        size: 18,
                        color: Color(0xFF929292),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      isLoading
                          ? CircularProgressIndicator() // Hiển thị khi đang tải
                          : Text(
                              NumberFormat.currency(locale: 'vi_VN', symbol: '')
                                  .format(totalRevenue1),
                              style: TextStyle(
                                fontSize: 36,
                              ),
                            ),
                      Spacer(),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            // Kiểm tra giá trị và hiển thị icon tương ứng
                            Image.asset(
                              (totalRevenue3) < 0
                                  ? 'assets/triangle1.png' // Đường dẫn tới icon mũi tên xuống
                                  : 'assets/triangle.png', // Đường dẫn tới icon mũi tên lên
                              width: 10,
                              height: 10,
                              color: (totalRevenue3) < 0
                                  ? Colors.red
                                  : Colors.green, // Đổi màu icon
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${(totalRevenue3.abs() * 0.1).toStringAsFixed(1)}%', // Giá trị luôn dương
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 5,
            ),

            // Đường kẻ thẳng ngăn cách
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFF2F3F4),
                thickness: 1,
              ),
            ),

            SizedBox(
              height: 5,
            ),

            // Hàng thứ hai: hiển thị 4 icon chia đều ở đây
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 20), // khoảng cách lề cho Container
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Số lượt bán',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF929292),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${totalRevenue4}',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Thu nhập',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF929292),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        formatNumberShort(totalRevenue),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Chi tiêu',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF929292),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        formatNumberShort1(totalRevenue2),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(
              height: 5,
            ),

            // Đường kẻ thẳng ngăn cách
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFF2F3F4),
                thickness: 1,
              ),
            ),

            SizedBox(
              height: 5,
            ),

            // Hàng thứ 3
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20),
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     // Text đầu tiên: "Số bàn đang có khách: 15"
              //     Row(
              //       children: [
              //         Text(
              //           'Bàn ăn đang có khách: ',
              //           style: TextStyle(
              //             color: Color(0xFF929292),
              //             fontSize: 13,
              //           ),
              //         ),
              //         Text(
              //           '${totalRevenue5}',
              //           style: TextStyle(
              //             color: Color(0xFFEF4D2D),
              //             fontSize: 13,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ),

            SizedBox(
              height: 10,
            ),

            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Danh sách các icon và text
                  GridView.builder(
                    shrinkWrap:
                        true, // Để GridView không chiếm toàn bộ không gian
                    physics:
                        NeverScrollableScrollPhysics(), // Vô hiệu cuộn trong GridView
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 mục trên mỗi hàng
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: iconsData.length,
                    itemBuilder: (context, index) {
                      final item = iconsData[index];
                      return GestureDetector(
                        onTap: () {
                          // Nếu có route, điều hướng đến màn hình tương ứng
                          if (item['route'] != null) {
                            Navigator.pushNamed(context, item['route']);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Hình tròn màu xám
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: item['color'], // Màu xám
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    item['imagePath'], // Hình ảnh icon
                                    width: 20, // Kích thước icon
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                item['name'],
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 5,
            ),

            // Đường kẻ thẳng ngăn cách
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFF2F3F4),
                thickness: 1,
              ),
            ),

            SizedBox(
              height: 15,
            ),

            // Hàng thứ 3
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: Row(
                    children: [
                      Image.asset(
                        'assets/bill_2.png',
                        height: 22,
                        width: 22,
                        color: Color(0xFFEF4D2D),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Lịch sử Hóa đơn',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  )),
                  GestureDetector(
                    onTap: () {
                      // Chuyển đến màn hình mới
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InvoiceScreen(), // Chuyển đến màn hình mới
                        ),
                      );
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Text(
                            'Xem chi tiết',
                            style: TextStyle(
                              color: Color(0xFFEF4D2D),
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 12,
            ),

            Container(
              // margin: EdgeInsets.all(20), // Khoảng cách với các phần tử khác
              // padding: EdgeInsets.all(10), // Khoảng cách bên trong container
              decoration: BoxDecoration(
                color: Colors.white, // Màu nền của ô
                borderRadius: BorderRadius.circular(0), // Bo góc
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black12, // Màu của bóng
                //     blurRadius: 5, // Độ mờ của bóng
                //     offset: Offset(0, 2), // Độ dịch chuyển bóng
                //   ),
                // ],
              ),
              height: 300, // Chiều cao của ô vuông
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _invoicesFuture, // Sử dụng biến Future đã khởi tạo
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator()); // Loading
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text("Lỗi: ${snapshot.error}")); // Hiển thị lỗi
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Không có dữ liệu.")); // Không có dữ liệu
                  } else {
                    // Hiển thị dữ liệu trả về
                    final invoices = snapshot.data!;
                    return ListView.builder(
                      itemCount: invoices.length,
                      itemBuilder: (context, index) {
                        final item = invoices[index];
                        return ListTile(
                          leading: item['invoice_type'] == 1
                              ? Image.asset(
                                  'assets/up.png', // Đường dẫn đến hình ảnh trong assets
                                  width: 24,
                                  height: 24,
                                  color: Colors.green,
                                )
                              : Image.asset(
                                  'assets/down.png', // Đường dẫn đến hình ảnh trong assets
                                  width: 24,
                                  height: 24,
                                  color: Colors.black,
                                ),
                          title: Text(
                              '${item['invoice_name']}'), // invoice_food_id
                          subtitle: Text(
                            '${item['describe']}',
                            style: TextStyle(
                                // fontSize: 12,
                                color: Color(0xFFABB2B9)),
                          ), // sale_percent
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${item['invoice_type'] == 1 ? '+' : '-'}${formatCurrency(item['money'].toString())}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: item['invoice_type'] == 1
                                      ? Colors.green
                                      : Colors.black, // Màu tiền
                                ),
                              ),
                              Text(
                                formatDate(item['created_at']),
                                style: TextStyle(
                                    //  fontSize: 12,
                                    color: Color(0xFFABB2B9)),
                              ), // payment_method
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
