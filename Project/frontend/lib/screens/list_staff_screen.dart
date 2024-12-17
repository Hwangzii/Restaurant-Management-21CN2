import 'package:flutter/material.dart';

class ListStaffScreen extends StatelessWidget {
  const ListStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('danh sách nhân sự', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}