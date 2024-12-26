// import 'package:app/file_test/test_home.dart';
import 'package:app/screens/bill_screen.dart';
import 'package:app/screens/history_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/invenory_screen.dart';
import 'package:app/screens/list_staff_screen.dart';
import 'package:app/screens/menu_options.dart';
import 'package:app/screens/order_screen.dart';
import 'package:app/screens/report_screen.dart';
import 'package:app/screens/staff_management_screen.dart';

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
    StaffManagementScreen(),
    BillScreen(),
    InventoryScreen(),
    ReportScreen(),
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
        color: Colors.white,
        height: 63,
        // notchMargin: 5.0, // Khoảng cách giữa nút và BottomAppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Chia đều các icon
          children: [
            _buildIconButton(
                'assets/home_1.png', 'assets/home_2.png', 'Trang chủ', 0),
            _buildIconButton(
                'assets/staff_1.png', 'assets/staff_2.png', 'Nhân sự', 1),
            _buildIconButton(
                'assets/bill_1.png', 'assets/bill_2.png', 'Hóa đơn', 2),
            _buildIconButton(
                'assets/box_1.png', 'assets/box_2.png', 'Kho hàng', 3),
            _buildIconButton(
                'assets/chart_1.png', 'assets/chart_2.png', 'Báo cáo', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
      String activeIcon, String inactiveIcon, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        decoration: BoxDecoration(
            // color: _selectedIndex == index ? Colors.white.withOpacity(0.1) : Colors.,
            // borderRadius: BorderRadius.circular(8),
            // border: Border.all(
            //   color: _selectedIndex == index ? Colors.transparent : Colors.transparent,
            //   width: 1,
            // ),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              _selectedIndex == index ? activeIcon : inactiveIcon,
              width: 20,
              height: 20,
            ),
            const SizedBox(height: 3), // Khoảng cách giữa icon và text
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    _selectedIndex == index ? Color(0xFFFF8A00) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
