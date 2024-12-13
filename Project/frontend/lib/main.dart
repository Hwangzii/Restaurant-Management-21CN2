import 'package:app/screens/login_screen.dart';
import 'package:app/screens/order_food_screen.dart';
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
            OrderFoodScreen(), // Đăng ký route cho màn hình EnterOtpScreen
        // '/home': (context) => const ManagerScreen(),  // Đăng ký route cho màn hình ManagerScreen
      },
    );
  }
}
