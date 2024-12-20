import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
        ),
        title: Text('Bàn 101'),
        centerTitle: true, // Căn giữa tiêu đề
        backgroundColor: Colors.blue, // Màu nền AppBar
      ),
      body: Center(
        child: Text(
          'Nội dung chính của Bàn 101',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

