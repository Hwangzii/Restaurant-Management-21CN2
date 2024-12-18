import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Giao diện thay đổi mật khẩu', style: TextStyle(
          fontSize: 24,
        ),),
      ),
    );
  }
}