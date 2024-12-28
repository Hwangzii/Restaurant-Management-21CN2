import 'package:app/models/user.dart';
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
    'imagePath': 'assets/clients.png',
    'name': 'khách hàng',
    'color': commonIconBackgroundColor
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

  double totalRevenue = 0.0;
  double totalRevenue1 = 0.0;
  double totalRevenue2 = 0.0;
  double totalRevenue3 = 0.0;
  int totalRevenue4 = 0;
  int totalRevenue5 = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTotalRevenue();
    fetchTotalRevenue1(); // Gọi hàm để lấy dữ liệu tổng doanh thu
    fetchTotalRevenue2();
    fetchTotalRevenue3();
    fetchTotalRevenue4();
    fetchTotalRevenue5();
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
                backgroundImage: AssetImage('assets/user_icon.png'),
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
                        'Tổng doanh thu (VNĐ)',
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
                                  .format(totalRevenue),
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
                              '${(totalRevenue3.abs() * 100)}%', // Giá trị luôn dương
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
                        formatNumberShort(totalRevenue1),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text đầu tiên: "Số bàn đang có khách: 15"
                  Row(
                    children: [
                      Text(
                        'Bàn ăn đang có khách: ',
                        style: TextStyle(
                          color: Color(0xFF929292),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${totalRevenue5}',
                        style: TextStyle(
                          color: Color(0xFFFF8A00),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  // "Xem chi tiết" + icon mũi tên
                  Row(
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          color: Color(0xFFFF8A00),
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
                ],
              ),
            ),

            SizedBox(
              height: 20,
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
              height: 5,
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Căn giữa và cách đều
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Lịch sử hóa đơn',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/reload.png',
                    height: 20,
                    width: 20,
                    color: Color(0xFFFF8A00),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.all(20), // Khoảng cách với các phần tử khác
              padding: EdgeInsets.all(10), // Khoảng cách bên trong container
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Màu nền của ô
                borderRadius: BorderRadius.circular(10), // Bo góc
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12, // Màu của bóng
                    blurRadius: 5, // Độ mờ của bóng
                    offset: Offset(0, 2), // Độ dịch chuyển bóng
                  ),
                ],
              ),
              // width: 150, // Chiều rộng của ô vuông
              height: 150, // Chiều cao của ô vuông
              child: Center(
                child: Text(
                  'Hóa đơn',
                  style: TextStyle(
                    fontSize: 18, // Cỡ chữ
                    color: Colors.white, // Màu chữ
                    fontWeight: FontWeight.bold, // Độ đậm của chữ
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
