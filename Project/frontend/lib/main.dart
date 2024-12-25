import 'package:app/screens/home_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/manager_screen.dart';
import 'package:app/screens/order_food_screen.dart';
import 'package:app/screens/add_staff_screen.dart';
import 'package:app/screens/pay_print_screen.dart';
import 'package:app/screens/shift_registration_screen.dart';
import 'package:app/screens/staff_check_screen.dart';
import 'package:app/screens/tables_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/food_screen.dart';
import 'package:app/screens/payroll_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Flutter App',
      initialRoute: '/', // Màn hình đầu tiên khi app chạy là EnterOtpScreen
      routes: {
        '/': (context) => ManagerScreen(),
        '/TablesScreen': (context) => TablesScreen(),
        '/StaffCheckScreen': (context) => StaffCheckScreen(),
        '/PayPrintScreen': (context) => PayPrintScreen(),
        '/FoodScreen' : (context) => FoodScreen(),
        '/PayrollScreen' : (context) => PayrollScreen()


      },
    );
  }
}
