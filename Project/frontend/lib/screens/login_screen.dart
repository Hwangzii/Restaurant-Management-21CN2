import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Biến kiểm tra mật khẩu có hiển thị không

  // Giao diện màn hình đăng nhập
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa toàn bộ nội dung
          children: [
            // Logo và tiêu đề
            Image.asset('assets/chef_logo.png', height: 100, width: 100),
            const SizedBox(height: 20),

            // Dòng chữ KOREAN FOOD
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'KOREAN',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'FOOD',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),

            // Form đăng nhập
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 700
                    ? (MediaQuery.of(context).size.width - 700) / 2
                    : 16, // Thêm khoảng cách cho các thiết bị nhỏ
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái cho nội dung
                children: <Widget>[
                  // Phần nhập tài khoản
                  _buildInputField(
                    context,
                    controller: _usernameController,
                    hintText: "Tài khoản",
                    iconPath: 'assets/user_icon.png',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),

                  // Phần nhập mật khẩu
                  _buildInputField(
                    context,
                    controller: _passwordController,
                    hintText: "Mật khẩu",
                    iconPath: 'assets/lock_icon.png',
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Image.asset(
                        _isPasswordVisible
                            ? 'assets/eye_closed.png'
                            : 'assets/eye_show.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Nút Đăng nhập
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.orange,
                    ),
                    child: InkWell(
                      onTap: () {
                        LoginController.handleLogin(
                          context,
                          _usernameController.text,
                          _passwordController.text,
                        );
                      },
                      child: const Center(
                        child: Text(
                          "Đăng nhập",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo các trường nhập liệu
  Widget _buildInputField(BuildContext context,
      {required TextEditingController controller,
      required String hintText,
      required String iconPath,
      required bool obscureText,
      Widget? suffixIcon}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F4),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(iconPath, height: 24, width: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[500]!,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }
}
