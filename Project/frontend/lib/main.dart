// main.dart
import 'package:flutter/material.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/home_screen.dart'; // Đảm bảo bạn import đúng HomeScreen

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
        '/': (context) => LoginScreen(),  // Đăng ký route cho màn hình Login
        '/home': (context) => const HomeScreen(),  // Đăng ký route cho màn hình Home
      },
    );
  }
}
