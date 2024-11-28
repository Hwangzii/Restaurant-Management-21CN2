import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Trang chủ', 
          style: TextStyle(
            fontSize: 24
            )
          ),
      ),
    );
  }
}
