import 'package:flutter/material.dart';

class TestHome extends StatefulWidget {
  const TestHome({super.key});

  @override
  State<TestHome> createState() => _TestHomeState();
}

class _TestHomeState extends State<TestHome> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Tiêu đề ở giữa
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Tầng 1',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Nội dung nửa trên và nửa dưới
              Expanded(
                child: Column(
                  children: [
                    // Nửa trên
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey,
                        
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}