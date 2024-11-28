// main.dart
import 'package:app/screens/test_api.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/positon_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/manager_screen.dart'; // Đảm bảo bạn import đúng HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      initialRoute: '/',  // Màn hình đầu tiên khi app chạy là LoginScreen
      routes: {
        '/': (context) => PositionScreen(),  // Đăng ký route cho màn hình Login
        '/home': (context) => const ManagerScreen(),  // Đăng ký route cho màn hình Home
      },
    );
  }
}

