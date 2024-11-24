import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Trang chủ'),
        ),
        body: const Center(
          child: Text(
            'Trang chủ',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
