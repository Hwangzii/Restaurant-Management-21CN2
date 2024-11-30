import 'package:flutter/material.dart';
import 'package:app/screens/enter_otp_screen.dart';
import 'package:app/screens/manager_screen.dart'; // Màn hình chính sau khi đăng nhập thành công
import 'package:app/screens/login_screen.dart'; // Màn hình đăng nhập

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      initialRoute: '/', // Đảm bảo rằng màn hình đầu tiên là màn hình đăng nhập
      routes: {
        '/': (context) => LoginScreen(), // Màn hình đăng nhập
        '/home': (context) =>
            ManagerScreen(), // Màn hình chính sau khi đăng nhập thành công
        '/otp': (context) => EnterOtpScreen(
            qrCodeUrl: '', username: ''), // Màn hình nhập OTP nếu cần
      },
    );
  }
}
