import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
bool _isFormValid() {
  return _currentPasswordController.text.isNotEmpty &&
      _newPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty &&
      _isNewPasswordLengthValid &&
      _isNewPasswordContainsLetterAndNumber &&
      _isNewPasswordContainsSpecialChar(_newPasswordController.text) &&
      _isPasswordsMatching;
}

  bool _isObscureCurrent = true; // Visibility for current password
  bool _isObscureNew = true;     // Visibility for new password
  bool _isObscureConfirm = true; // Visibility for confirm password

  // Trạng thái kiểm tra mật khẩu mới
  bool _isNewPasswordLengthValid = false;
  bool _isNewPasswordContainsLetterAndNumber = false;
  bool _isPasswordsMatching = false;
  
  // Kiểm tra mật khẩu có chứa ký tự đặc biệt hay không
  bool _isNewPasswordContainsSpecialChar(String password) {
    final specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return specialCharRegExp.hasMatch(password);
  }

  // Kiểm tra tính hợp lệ của mật khẩu hiện tại
  bool _isCurrentPasswordValid(String password) {
    return password.isNotEmpty && password.length >= 8 && password.length <= 30;
  }

  // Kiểm tra mật khẩu mới
  void _validateNewPassword(String value) {
    setState(() {
      _isNewPasswordLengthValid = value.length >= 8 && value.length <= 30;
      _isNewPasswordContainsLetterAndNumber =
          RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]').hasMatch(value);
      _isPasswordsMatching =
          _newPasswordController.text == _confirmPasswordController.text;
    });
  }

  // Kiểm tra nhập lại mật khẩu mới
  void _validateConfirmPassword(String value) {
    setState(() {
      _isPasswordsMatching =
          _newPasswordController.text == _confirmPasswordController.text;
    });
  }

  // Thay đổi mật khẩu
  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thay đổi mật khẩu thành công!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thay đổi mật khẩu",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mật khẩu hiện tại
              Text(
                'Mật khẩu hiện tại',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _isObscureCurrent,
                decoration: InputDecoration(
                  hintText: 'Hãy nhập mật khẩu hiện tại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureCurrent ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureCurrent = !_isObscureCurrent;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (!_isCurrentPasswordValid(value ?? '')) {
                    return 'Mật khẩu hiện tại không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Mật khẩu mới
              Text(
                'Mật khẩu mới',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _isObscureNew,
                decoration: InputDecoration(
                  hintText: 'Hãy nhập mật khẩu mới',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureNew ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureNew = !_isObscureNew;
                      });
                    },
                  ),
                ),
                onChanged: _validateNewPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (!_isNewPasswordLengthValid) {
                    return 'Mật khẩu phải có từ 8 đến 30 ký tự';
                  }
                  // Kiểm tra có ký tự đặc biệt
                  if (!_isNewPasswordContainsSpecialChar(value)) {
                    return 'Mật khẩu phải bao gồm cả chữ cái, số và ký tự đặc biệt';
                  }
                  return null;
                },
              ),

              // Kiểm tra mật khẩu mới
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _newPasswordController.text.isEmpty
                            ? Icons.error
                            : (_isNewPasswordLengthValid
                                ? Icons.check_circle
                                : Icons.error),
                        color: _newPasswordController.text.isEmpty
                            ? Colors.white
                            : (_isNewPasswordLengthValid
                                ? Colors.green
                                : Colors.red),
                      ),
                      SizedBox(width: 5),
                      Text('Mật khẩu có từ 8 đến 30 ký tự'),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        _newPasswordController.text.isEmpty
                            ? Icons.error
                            : (_isNewPasswordContainsLetterAndNumber
                                ? Icons.check_circle
                                : Icons.error),
                        color: _newPasswordController.text.isEmpty
                            ? Colors.white
                            : (_isNewPasswordContainsLetterAndNumber
                                ? Colors.green
                                : Colors.red),
                      ),
                      SizedBox(width: 5),
                      Text('Mật khẩu bao gồm chữ cái và số'),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        _newPasswordController.text.isEmpty
                            ? Icons.error
                            : (_isNewPasswordContainsSpecialChar(
                                    _newPasswordController.text)
                                ? Icons.check_circle
                                : Icons.error),
                        color: _newPasswordController.text.isEmpty
                            ? Colors.white
                            : (_isNewPasswordContainsSpecialChar(
                                    _newPasswordController.text)
                                ? Colors.green
                                : Colors.red),
                      ),
                      SizedBox(width: 5),
                      Text('Mật khẩu bao gồm ký tự đặc biệt'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Nhập lại mật khẩu mới
              Text(
                'Nhập lại mật khẩu mới',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isObscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Hãy nhập lại mật khẩu mới',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureConfirm = !_isObscureConfirm;
                      });
                    },
                  ),
                ),
                onChanged: _validateConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập lại mật khẩu';
                  }
                  if (!_isPasswordsMatching) {
                    return 'Mật khẩu mới và mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Kiểm tra khớp mật khẩu
Row(
  children: [
    Icon(
      _confirmPasswordController.text.isEmpty
          ? Icons.error
          : (_isPasswordsMatching
              ? Icons.check_circle
              : Icons.error),
      color: _confirmPasswordController.text.isEmpty
          ? Colors.white
          : (_isPasswordsMatching
              ? Colors.green
              : Colors.red),
    ),
    SizedBox(width: 5),
    Text(
      _confirmPasswordController.text.isEmpty
          ? ''
          : (_isPasswordsMatching ? 'Mật khẩu mới và mật khẩu xác nhận khớp' : 'Mật khẩu mới và mật khẩu xác nhận không khớp'),
      style: TextStyle(
        color: _confirmPasswordController.text.isEmpty
            ? Colors.transparent
            : (_isPasswordsMatching ? Colors.green : Colors.red),
      ),
    ),
  ],
),
SizedBox(height: 30),


              // Nút thay đổi mật khẩu
Center(
  child: Container(
    width: screenWidth * 0.9,
    child: ElevatedButton(
      onPressed: _currentPasswordController.text.isNotEmpty &&
              _newPasswordController.text.isNotEmpty &&
              _confirmPasswordController.text.isNotEmpty &&
              _isNewPasswordLengthValid &&
              _isNewPasswordContainsLetterAndNumber &&
              _isNewPasswordContainsSpecialChar(
                  _newPasswordController.text) &&
              _isPasswordsMatching
          ? _changePassword
          : null,
      child: Text(
        'Thay đổi mật khẩu',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentPasswordController.text.isNotEmpty &&
                _newPasswordController.text.isNotEmpty &&
                _confirmPasswordController.text.isNotEmpty &&
                _isNewPasswordLengthValid &&
                _isNewPasswordContainsLetterAndNumber &&
                _isNewPasswordContainsSpecialChar(
                    _newPasswordController.text) &&
                _isPasswordsMatching
            ? Colors.blue
            : Colors.grey,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}
