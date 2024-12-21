import 'package:flutter/material.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Giao diện món ăn',
          style: TextStyle(
            fontSize: 30, 
          ),
        ),
      ),
    );
  }
}