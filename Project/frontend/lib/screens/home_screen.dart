import 'package:app/screens/order_food_screen.dart';
import 'package:app/screens/tables_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/controllers/notification_controller.dart'; // Import controller

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Biến màu chung
const Color commonIconBackgroundColor = Color(0xFFF5F5F5);

// Danh sách dữ liệu icon
final List<Map<String, dynamic>> iconsData = [
  {'imagePath': 'assets/food.png', 'name': 'Món ăn', 'color': commonIconBackgroundColor,},
  {'imagePath': 'assets/clients.png', 'name': 'khách hàng', 'color': commonIconBackgroundColor},
  {'imagePath': 'assets/order.png', 'name': 'Gọi món', 'color': commonIconBackgroundColor, 'route': '/TablesScreen'},
  {'imagePath': 'assets/staff_check.png', 'name': 'Điểm danh', 'color': commonIconBackgroundColor, 'route': '/StaffCheckScreen'},
  {'imagePath': 'assets/food.png', 'name': 'Khuyến mãi', 'color': commonIconBackgroundColor},
  {'imagePath': 'assets/food.png', 'name': 'Gọi món', 'color': commonIconBackgroundColor},
  {'imagePath': 'assets/food.png', 'name': 'Thanh toán', 'color': commonIconBackgroundColor},
  {'imagePath': 'assets/food.png', 'name': 'Thông báo', 'color': commonIconBackgroundColor},
];
       

class _HomeScreenState extends State<HomeScreen> {
  final NotificationController _notificationController =
      NotificationController(); // Khởi tạo controller

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình
    double screenWidth = MediaQuery.of(context).size.width;
    
    // Chiều rộng của container đầu tiên sẽ bằng với chiều rộng của 4 ô vuông trong GridView
    double containerWidth = (screenWidth - 3 * 10) / 4; // Trừ đi khoảng cách giữa các ô vuông

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon avatar với kích thước nhỏ hơn
            CircleAvatar(
              radius: 15, // Kích thước avatar
              backgroundImage: AssetImage('assets/user_icon.png'),
            ),

            // Thanh tìm kiếm
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 30,
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    hintText: 'Tìm kiếm...',
                    hintStyle: TextStyle(color: Color(0xFFABB2B9)),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                  ),
                ),
              ),
            ),

            // Icon thông báo với sự kiện click
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _notificationController.incrementNotification(); // Gọi hàm tăng số thông báo
                    });
                  },
                  icon: Image.asset(
                    'assets/bell.png',
                    width: 18,
                    height: 18,
                  ),
                ),
                if (_notificationController.getNotificationCount() > 0)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_notificationController.getNotificationCount()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
            SizedBox(height: 10),
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
                        'tổng doanh thu (VNĐ)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF929292),
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.remove_red_eye,
                        size: 18,
                        color: Color(0xFF929292),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '100.000.000,0',
                        style: TextStyle(
                          fontSize: 28,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/triangle.png',
                              width: 10,
                              height: 10,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '8,2%',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        
            SizedBox(height: 2,),
        
            // Đường kẻ thẳng ngăn cách
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFF2F3F4),
                thickness: 1,
              ),
            ),
        
            SizedBox(height: 2,),  
        
            
            // Hàng thứ hai: hiển thị 4 icon chia đều ở đây
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20), // khoảng cách lề cho Container
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
                      SizedBox(height: 5,),
                      Text(
                        '472',
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
                      SizedBox(height: 5,),
                      Text(
                        '+180.0 tr',
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
                      SizedBox(height: 5,),
                      Text(
                        '-80.0 tr',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                  
                ],
              ),
            ),
        
            SizedBox(height: 5,),
        
            // Đường kẻ thẳng ngăn cách
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFF2F3F4),
                thickness: 1,
              ),
            ),
        
            SizedBox(height: 2,),
        
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
                        '15',
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
        
            SizedBox(height: 20,),
        
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Danh sách các icon và text
                  GridView.builder(
                    shrinkWrap: true, // Để GridView không chiếm toàn bộ không gian
                    physics: NeverScrollableScrollPhysics(), // Vô hiệu cuộn trong GridView
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 mục trên mỗi hàng
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: iconsData.length,
                    itemBuilder: (context, index) {
                      final item = iconsData[index];
                      return GestureDetector(
                        onTap: (){
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
                                style: TextStyle(fontSize: 13, color: Colors.black),
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
          ],
        ),
      ),
    );
  }
}
