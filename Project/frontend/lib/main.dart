import 'package:app/screens/login_screen.dart';
import 'package:app/screens/manager_screen.dart';
import 'package:app/screens/order_food_screen.dart';
import 'package:app/screens/add_staff_screen.dart';
import 'package:app/screens/tables_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Flutter App',
      initialRoute: '/', // Màn hình đầu tiên khi app chạy là EnterOtpScreen
      routes: {
        '/': (context) =>
            ManagerScreen(),
            // ManagerScreen(),
        // '/home': (context) => const ManagerScreen(),  // Đăng ký route cho màn hình ManagerScreen
      },
    );
  }
}
