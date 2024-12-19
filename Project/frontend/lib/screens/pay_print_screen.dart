import 'package:flutter/material.dart';

class PayPrintScreen extends StatelessWidget {
  const PayPrintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
        ),
        title: Text('Bàn 101'),
        centerTitle: true, // Căn giữa tiêu đề
        backgroundColor: Colors.white, // Màu nền AppBar
      ),
      body: Column(
        children: [
          // Thanh tiêu đề 3 cột
          Container(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 5),
            color: Colors.white, // Màu nền cho tiêu đề
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Tên món',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF929292),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'SL',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF929292),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Giá',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF929292),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // ListView với nền trắng
          Expanded(
            child: Container(
              color: Colors.white, // Nền màu trắng
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          // Bỏ phần boxShadow để không có đổ bóng
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Hiển thị tên món
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black
                                    ),
                                  ),
                                  SizedBox(height: 4), // Khoảng cách giữa tên món và thời gian
                                  Text(
                                    item.time, // Hiển thị thời gian
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Hiển thị số lượng
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Hiển thị giá
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item.price.toStringAsFixed(0)} đ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  SizedBox(height: 4), // Khoảng cách giữa giá và trạng thái
                                  // Thay thế Icon check và Icon hourglass_empty bằng hình ảnh tùy chỉnh
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Hiển thị trạng thái (hình ảnh check hoặc hourglass)
                                      Image.asset(
                                        item.isProcessed
                                            ? 'assets/check.png' // Hình ảnh cho trạng thái đã xử lý
                                            : 'assets/clock.png', // Hình ảnh cho trạng thái đang xử lý
                                        width: 12, // Chiều rộng hình ảnh
                                        height: 12, // Chiều cao hình ảnh
                                        fit: BoxFit.contain, // Điều chỉnh kích thước hình ảnh phù hợp
                                      ),
                                    ],
                                  )

                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Đường kẻ mờ nhạt giữa các item
                      Divider(
                        color: Colors.grey[300], // Màu sắc của đường kẻ
                        thickness: 1, // Độ dày của đường kẻ
                        indent: 16, // Khoảng cách từ bên trái
                        endIndent: 16, // Khoảng cách từ bên phải
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lớp dữ liệu mẫu
class MenuItem {
  final String name; // Tên món
  final int quantity; // Số lượng
  final double price; // Giá
  final String time; // Thời gian
  final bool isProcessed; // Trạng thái

  MenuItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.time,
    required this.isProcessed,
  });
}

// Danh sách dữ liệu mẫu (24 món ăn)
final List<MenuItem> menuItems = [
  MenuItem(name: 'Phở bò', quantity: 2, price: 50000, time: '12:30', isProcessed: true),
  MenuItem(name: 'Bún chả', quantity: 1, price: 45000, time: '12:35', isProcessed: false),
  MenuItem(name: 'Nem rán', quantity: 3, price: 30000, time: '12:40', isProcessed: true),
  MenuItem(name: 'Trà đá', quantity: 4, price: 10000, time: '12:45', isProcessed: false),
  MenuItem(name: 'Cơm gà xối mỡ', quantity: 1, price: 60000, time: '12:50', isProcessed: true),
  MenuItem(name: 'Hủ tiếu', quantity: 2, price: 40000, time: '12:55', isProcessed: false),
  MenuItem(name: 'Cháo sườn', quantity: 1, price: 35000, time: '13:00', isProcessed: true),
  MenuItem(name: 'Bánh mì thịt nướng', quantity: 2, price: 25000, time: '13:05', isProcessed: true),
  MenuItem(name: 'Súp cua', quantity: 3, price: 20000, time: '13:10', isProcessed: false),
  MenuItem(name: 'Mì Quảng', quantity: 2, price: 55000, time: '13:15', isProcessed: true),
  MenuItem(name: 'Bánh cuốn', quantity: 1, price: 40000, time: '13:20', isProcessed: false),
  MenuItem(name: 'Bún riêu cua', quantity: 2, price: 50000, time: '13:25', isProcessed: true),
  MenuItem(name: 'Gỏi cuốn', quantity: 3, price: 20000, time: '13:30', isProcessed: true),
  MenuItem(name: 'Bò lúc lắc', quantity: 2, price: 120000, time: '13:35', isProcessed: false),
  MenuItem(name: 'Gà chiên nước mắm', quantity: 1, price: 85000, time: '13:40', isProcessed: true),
  MenuItem(name: 'Cá kho tộ', quantity: 1, price: 90000, time: '13:45', isProcessed: false),
  MenuItem(name: 'Lẩu thái', quantity: 1, price: 150000, time: '13:50', isProcessed: true),
  MenuItem(name: 'Lẩu gà lá é', quantity: 1, price: 180000, time: '13:55', isProcessed: false),
  MenuItem(name: 'Xôi gà', quantity: 2, price: 40000, time: '14:00', isProcessed: true),
  MenuItem(name: 'Chả cá Lã Vọng', quantity: 1, price: 200000, time: '14:05', isProcessed: false),
  MenuItem(name: 'Bún bò Huế', quantity: 2, price: 55000, time: '14:10', isProcessed: true),
  MenuItem(name: 'Cơm tấm sườn bì', quantity: 1, price: 50000, time: '14:15', isProcessed: false),
  MenuItem(name: 'Nước mía', quantity: 3, price: 15000, time: '14:20', isProcessed: true),
  MenuItem(name: 'Sinh tố bơ', quantity: 1, price: 30000, time: '14:25', isProcessed: false),
];
