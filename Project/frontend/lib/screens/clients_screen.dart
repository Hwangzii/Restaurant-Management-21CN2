import 'package:flutter/material.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Giao diện danh sách khách hàng',
          style: TextStyle(
            fontSize: 30, 
          ),
        ),
      ),
    );
  }
}