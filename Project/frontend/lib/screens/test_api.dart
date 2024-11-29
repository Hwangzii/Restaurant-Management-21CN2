// screens/test_api.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestApiScreen extends StatefulWidget {
  @override
  _TestApiScreenState createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  List<dynamic> accounts = [];

  // Hàm gọi API và lấy dữ liệu
  Future<void> fetchAccounts() async {
    final String apiUrl = '';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          accounts = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load accounts');
      }
    } catch (e) {
      print('Error fetching accounts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAccounts(); // Gọi API khi widget được khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test API Data'),
      ),
      body: accounts.isEmpty
          ? Center(child: CircularProgressIndicator()) // Hiển thị vòng quay chờ khi chưa có dữ liệu
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                // Tạo widget cho từng item trong danh sách dữ liệu từ API
                return ListTile(
                  title: Text('Username: ${accounts[index]['username']}'),
                  subtitle: Text('Password: ${accounts[index]['password']}'),
                  trailing: Text('ID: ${accounts[index]['id']}'),
                );
              },
            ),
    );
  }
}
