import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';  // Để hiển thị thông báo

class EnterOtpScreen extends StatefulWidget {
  @override
  _EnterOtpScreenState createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  // Controller cho các ô nhập OTP
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();
  final TextEditingController _otpController5 = TextEditingController();
  final TextEditingController _otpController6 = TextEditingController();

  // Hàm để gửi mã OTP
  void _sendOtp() {
    String otp = _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text +
        _otpController5.text +
        _otpController6.text;

    if (otp.length == 6) {
      // Kiểm tra mã OTP
      bool isValid = _verifyOtp(otp);
      if (isValid) {
        // Hiển thị thông báo đăng nhập thành công
        Fluttertoast.showToast(
          msg: "Bạn đã nhập đúng mã OTP!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );

        // Chuyển sang màn hình Home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Nếu OTP sai
        Fluttertoast.showToast(
          msg: "Mã OTP sai. Vui lòng thử lại.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Vui lòng nhập đủ 6 chữ số OTP.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  // Hàm kiểm tra mã OTP
  bool _verifyOtp(String otp) {
    // Kiểm tra mã OTP đã tạo
    String correctOtp = "NHP";  // Mã OTP đã tạo
    return otp == correctOtp;
  }

  // Hàm để tự động chuyển đến ô nhập OTP tiếp theo
  void _onOtpChanged(String value, TextEditingController currentController, TextEditingController? nextController) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(FocusNode());  // Ẩn bàn phím
      if (nextController != null) {
        FocusScope.of(context).requestFocus(FocusNode());  // Đưa focus vào ô tiếp theo
        FocusScope.of(context).requestFocus(FocusNode());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhập Mã OTP'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tạo 6 ô nhập mã OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOtpField(_otpController1, _otpController2),
                _buildOtpField(_otpController2, _otpController3),
                _buildOtpField(_otpController3, _otpController4),
                _buildOtpField(_otpController4, _otpController5),
                _buildOtpField(_otpController5, _otpController6),
                _buildOtpField(_otpController6, null),  // Không có controller tiếp theo cho ô cuối
              ],
            ),
            SizedBox(height: 20),
            // Nút Gửi mã
            ElevatedButton(
              onPressed: _sendOtp,
              child: Text('Gửi Mã'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget để xây dựng các ô nhập OTP
  Widget _buildOtpField(TextEditingController currentController, TextEditingController? nextController) {
    return Container(
      width: 50,
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: currentController,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: (value) {
          _onOtpChanged(value, currentController, nextController);
        },
        decoration: InputDecoration(
          counterText: "", // Ẩn số đếm ký tự
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
