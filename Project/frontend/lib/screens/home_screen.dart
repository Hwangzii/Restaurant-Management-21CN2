import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon avatar
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/user_icon.png'),
            ),

            // Thanh tìm kiếm
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                height: 30,
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    hintText: 'Tìm kiếm...',
                    hintStyle: TextStyle(color: Color(0xFFABB2B9)),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                  ),
                ),
              ),
            ),
            

            // Icon thông báo
            IconButton(
              onPressed: (){
                // gọi hàm sự kiện tìm kiếm ở đây
              },
              icon: Image.asset(
                'assets/bell.png',
                width: 18,
                height: 18,
              )
            ),
          ],
        ),
      ),

      body: Center(
        
        child: Text('Trang chủ', style: TextStyle(fontSize: 24),),
      ),
    );
  }
}
