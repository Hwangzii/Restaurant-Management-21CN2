// main.dart
// import 'package:app/screens/login_screen.dart';
import 'package:app/screens/test_api.dart';
// import 'package:app/screens/test_api.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test APi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestApiScreen(), 
    );
  }
}
