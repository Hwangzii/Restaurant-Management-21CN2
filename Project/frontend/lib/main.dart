import 'package:app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/enter_otp_screen.dart';
import 'package:app/screens/manager_screen.dart'; // Đảm bảo bạn import đúng màn hình Manager

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      initialRoute: '/',  // Màn hình đầu tiên khi app chạy là EnterOtpScreen
      routes: {
        '/': (context) => HomeScreen(),  // Đăng ký route cho màn hình EnterOtpScreen
        '/home': (context) => const ManagerScreen(),  // Đăng ký route cho màn hình ManagerScreen
      },
    );
  }
}
