import 'package:app/screens/history_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/order_screen.dart';
import 'package:app/screens/warehouse_screen.dart';
import 'package:flutter/material.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManagerScreen> {
  int _selectedIndex = 0;

  // Danh sách các widget màn hình tương ứng cho từng mục trong BottomNavigationBar
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    OrderScreen(),
    WarehouseScreen(),
  ];

  // Hàm cập nhật chỉ số khi người dùng nhấn vào mục trong BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 0 ? 'assets/home_1.png' : 'assets/home_2.png',
              width: 25, height: 25,
            ), // Đặt đường dẫn hình ảnh tại đây
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 1 ? 'assets/history_1.png' : 'assets/history_2.png',
              width: 25, height: 25,
            ),
          
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2 ? 'assets/add_1.png' : 'assets/add_2.png',
              width: 25, height: 25,
            ),
            label: 'Gọi món',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 3 ? 'assets/box_1.png' : 'assets/box_2.png',
              width: 25, height: 25,
            ),
            label: 'Kho hàng',
          ),
        ],
        currentIndex: _selectedIndex, // Chỉ mục hiện tại
        selectedItemColor: Colors.orange, // Màu cho mục được chọn
        unselectedItemColor: Colors.grey, // Màu cho mục không được chọn
        onTap: _onItemTapped, // Xử lý sự kiện khi nhấn vào mục
        type: BottomNavigationBarType.fixed, // Hiển thị cố định cho 4 mục
      ),
    );
  }
}
