import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:app/services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final User user;

  const ChangePasswordScreen({Key? key, required this.user}) : super(key: key);

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
  bool _isObscureNew = true; // Visibility for new password
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
  void _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Lấy mật khẩu cũ, mật khẩu mới và mật khẩu xác nhận
      String oldPassword = _currentPasswordController.text;
      String newPassword = _newPasswordController.text;

      // Kiểm tra mật khẩu cũ đúng chưa
      if (oldPassword == widget.user.password) {
        // Gọi API để thay đổi mật khẩu
        ApiService apiService = ApiService();
        bool success = await apiService.changePassword(
          widget.user.id,
          oldPassword,
          newPassword,
        );

        // Xử lý phản hồi sau khi gọi API
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thay đổi mật khẩu thành công!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã có lỗi khi thay đổi mật khẩu!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mật khẩu cũ không đúng!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thay đổi mật khẩu',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        // backgroundColor: Colors.white,
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _isObscureCurrent,
                  decoration: InputDecoration(
                    hintText: 'Hãy nhập mật khẩu hiện tại',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Bo góc
                      borderSide: const BorderSide(
                        color: Colors.grey, // Màu viền xám
                        width: 0.5, // Độ dày viền
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureCurrent
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureCurrent = !_isObscureCurrent;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mật khẩu cũ không được để trống';
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
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _isObscureNew,
                  decoration: InputDecoration(
                    hintText: 'Hãy nhập mật khẩu mới',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Bo góc
                      borderSide: const BorderSide(
                        color: Colors.grey, // Màu viền xám
                        width: 0.5, // Độ dày viền
                      ),
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
                                  ? Color(0xFF2ECC71)
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
                                  ? Color(0xFF2ECC71)
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
                                  ? Color(0xFF2ECC71)
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
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isObscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Hãy nhập lại mật khẩu mới',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Bo góc
                      borderSide: const BorderSide(
                        color: Colors.grey, // Màu viền xám
                        width: 0.5, // Độ dày viền
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                              ? Color(0xFF2ECC71)
                              : Colors.red),
                    ),
                    SizedBox(width: 5),
                    Text(
                      _confirmPasswordController.text.isEmpty
                          ? ''
                          : (_isPasswordsMatching
                              ? 'Mật khẩu mới và mật khẩu xác nhận khớp'
                              : 'Mật khẩu mới và mật khẩu xác nhận không khớp'),
                      style: TextStyle(
                        color: _confirmPasswordController.text.isEmpty
                            ? Colors.transparent
                            : (_isPasswordsMatching
                                ? Color(0xFF2ECC71)
                                : Colors.red),
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
                        'Lưu thay đổi',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPasswordController
                                    .text.isNotEmpty &&
                                _newPasswordController.text.isNotEmpty &&
                                _confirmPasswordController.text.isNotEmpty &&
                                _isNewPasswordLengthValid &&
                                _isNewPasswordContainsLetterAndNumber &&
                                _isNewPasswordContainsSpecialChar(
                                    _newPasswordController.text) &&
                                _isPasswordsMatching
                            ? Color(0xFFEF4D2D)
                            : Color(0xFF808B96),
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
      ),
    );
  }
}
