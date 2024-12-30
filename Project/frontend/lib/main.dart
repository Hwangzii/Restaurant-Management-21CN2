import 'package:app/file_test/chart.dart';
import 'package:app/file_test/dash_board_page.dart';
import 'package:app/screens/manager_screen.dart';
import 'package:app/screens/masterchef_screen.dart';
import 'package:app/screens/staff_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/models/user.dart'; // Nhập khẩu lớp User
import 'package:app/services/api_service.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/food_screen.dart';
import 'package:app/screens/clients_screen.dart';
import 'package:app/screens/tables_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService apiService = ApiService();
  // Lấy dữ liệu người dùng từ API
  User user = await apiService.fetchUserData();

  // Chạy ứng dụng
  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User user;
  const MyApp({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/FoodScreen': (context) => FoodScreen(),
        '/ClientsScreen': (context) => ClientsScreen(),
        '/StaffCheckScreen': (context) => StaffCheckScreen(),
        '/TablesScreen': (context) => TablesScreen(user: user),
      },
    );
  }
}
