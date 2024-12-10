import 'package:flutter/material.dart';
import 'package:app/screens/enter_otp_screen.dart'; // Màn hình nhập OTP
import 'package:app/services/api_service.dart'; // Dịch vụ gọi API

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tài khoản và mật khẩu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loginResult = await ApiService().login(username, password);
      setState(() {
        _isLoading = false;
      });

      if (loginResult['success']) {
        if (loginResult['qrCodeUrl'] != null) {
          // Nếu có QR code (người dùng chưa bật 2FA)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnterOtpScreen(
                qrCodeUrl: loginResult['qrCodeUrl'], // Chuyển QR code
                username: username, // Truyền username
              ),
            ),
          );
        } else {
          // Nếu có QR code (người dùng chưa bật 2FA)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnterOtpScreen(
                qrCodeUrl: '', // Chuyển QR code
                username: username, // Truyền username
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tài khoản hoặc mật khẩu không đúng')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi, vui lòng thử lại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Tên đăng nhập'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child:
                  _isLoading ? CircularProgressIndicator() : Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
