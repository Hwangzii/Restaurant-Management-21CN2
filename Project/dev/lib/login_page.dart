import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controllers for username and password fields
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Tài khoản',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call the separate login function
                _handleLogin(
                  context,
                  usernameController.text,
                  passwordController.text,
                );
              },
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}

void _handleLogin(BuildContext context, String username, String password) {
  if (username.isEmpty || password.isEmpty) {
    // hiển thị thông báo nếu tài khoản hoặc mật khẩu trống
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng nhập tài khoản và mật khẩu đầy đủ'),
      ),
    );
  } else if (username == 'admin' && password == '123456') {
    // Điều hướng đến HomePage nếu tài khoản và mật khẩu đúng
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else {
    // Hiển thị thông báo lỗi nếu tài khoản hoặc mật khẩu không đúng
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tài khoản hoặc mật khẩu không đúng. Vui lòng thử lại!'),
      ),
    );
  }
}
