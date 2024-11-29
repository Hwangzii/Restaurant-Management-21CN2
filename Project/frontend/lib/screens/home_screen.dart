import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Phần trên với gradient màu cam
          Expanded(
            flex: 2, // Chiếm 20% chiều cao
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade200, Colors.orange.shade800],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Phần dưới với nền xám nhạt và các container màu trắng
          Expanded(
            flex: 8, // Chiếm 80% chiều cao
            child: Container(
              color: Colors.grey.shade100, // Màu xám nhạt
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(10, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Cách đều giữa các container
                      padding: EdgeInsets.all(15), // Padding bên trong container
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Container ${index + 1}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
