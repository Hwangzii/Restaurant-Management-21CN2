import 'package:flutter/material.dart';

class MenuOptionsScreen extends StatelessWidget {
  const MenuOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Danh mục tùy chọn', style: TextStyle(fontSize: 24)),
      ),
    );  
  }
}