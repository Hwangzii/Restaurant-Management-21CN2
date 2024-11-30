import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app/services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Đảm bảo import ApiService

class EnterOtpScreen extends StatefulWidget {
  final String qrCodeUrl;
  final String username; // Thêm trường username

  const EnterOtpScreen(
      {Key? key, required this.qrCodeUrl, required this.username})
      : super(key: key);

  @override
  _EnterOtpScreenState createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();
  final TextEditingController _otpController5 = TextEditingController();
  final TextEditingController _otpController6 = TextEditingController();

  final ApiService _apiService = ApiService();

  late FocusNode _focusNode1,
      _focusNode2,
      _focusNode3,
      _focusNode4,
      _focusNode5,
      _focusNode6;

  @override
  void initState() {
    super.initState();
    _focusNode1 = FocusNode();
    _focusNode2 = FocusNode();
    _focusNode3 = FocusNode();
    _focusNode4 = FocusNode();
    _focusNode5 = FocusNode();
    _focusNode6 = FocusNode();
  }

  void _sendOtp() async {
    String otp = _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text +
        _otpController5.text +
        _otpController6.text;

    if (otp.length == 6) {
      // Gọi API xác thực OTP và truyền username
      final result = await _apiService.verifyOtp(
          widget.username, otp); // Gửi username và OTP tới API

      if (result['success']) {
        Fluttertoast.showToast(
          msg: "Xác thực OTP thành công",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Fluttertoast.showToast(
          msg: "Mã OTP không hợp lệ, vui lòng thử lại",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Vui lòng nhập đủ 6 chữ số OTP",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _focusNode5.dispose();
    _focusNode6.dispose();
    super.dispose();
  }

  Widget _buildOtpField(TextEditingController currentController,
      FocusNode currentFocusNode, FocusNode? nextFocusNode) {
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
        focusNode: currentFocusNode,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: (value) {
          if (value.isNotEmpty && nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        onEditingComplete: () {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nhập mã OTP')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.qrCodeUrl.isNotEmpty
                ? Column(
                    children: [
                      QrImageView(
                        data: widget.qrCodeUrl,
                        version: QrVersions.auto,
                        size: 300.0,
                      ),
                      SizedBox(height: 20),
                      Text('Quét mã QR trong ứng dụng Google Authenticator'),
                    ],
                  )
                : Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.grey[200],
                    child: Text('Nhập OTP'),
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOtpField(_otpController1, _focusNode1, _focusNode2),
                _buildOtpField(_otpController2, _focusNode2, _focusNode3),
                _buildOtpField(_otpController3, _focusNode3, _focusNode4),
                _buildOtpField(_otpController4, _focusNode4, _focusNode5),
                _buildOtpField(_otpController5, _focusNode5, _focusNode6),
                _buildOtpField(_otpController6, _focusNode6, null),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendOtp,
              child: Text('Xác thực OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
