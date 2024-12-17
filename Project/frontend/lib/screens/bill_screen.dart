import 'package:flutter/material.dart';

class BillScreen extends StatelessWidget {
  const BillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Giao diện hóa đơn', style: TextStyle(fontSize: 24),)),
    );
  }
}