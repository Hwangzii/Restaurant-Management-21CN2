// import 'package:app/file_test/test_home.dart';
import 'package:app/screens/history_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/menu_options.dart';
import 'package:app/screens/order_screen.dart';
import 'package:app/screens/tables_screen.dart';
import 'package:app/screens/warehouse_screen.dart';
import 'package:flutter/material.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({Key? key}) : super(key: key);

  @override
  _ManagerScreenState createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  int _selectedIndex = 0;

  // Danh sách các widget màn hình tương ứng cho từng mục trong BottomNavigationBar
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    OrderScreen(),
    HistoryScreen(),
    MenuOptions(),
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
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(), // Tạo khoảng trống cho nút nổi bật
        notchMargin: 10.0, // Khoảng cách giữa nút và BottomAppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Chia đều các icon
          children: [
            IconButton(
              icon: Image.asset(
                _selectedIndex == 0 ? 'assets/home_1.png' : 'assets/home_2.png',
                width: 22, height: 22,
              ),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Image.asset(
                _selectedIndex == 1 ? 'assets/add_1.png' : 'assets/add_2.png',
                width: 22, height: 22,
              ),
              onPressed: () => _onItemTapped(1),
            ),
            SizedBox(width: 40), // Khoảng trống cho nút nổi bật
            IconButton(
              icon: Image.asset(
                _selectedIndex == 2 ? 'assets/history_1.png' : 'assets/history_2.png',
                width: 22, height: 22,
              ),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Image.asset(
                _selectedIndex == 3 ? 'assets/menu_1.png' : 'assets/menu_2.png',
                width: 22, height: 22,
              ),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=> TablesScreen()),
            );
        },
        backgroundColor: Colors.orange, // Màu nền nút Add
        child: Icon(Icons.add, size: 30, color: Colors.white), // Icon của nút Add
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Vị trí nút Add
    );
  }
}
