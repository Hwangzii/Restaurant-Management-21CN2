import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:app/controllers/enter_otp_controller.dart';

class EnterOtpScreen extends StatelessWidget {
  final String username;
  final String qrCodeUrl;

  const EnterOtpScreen({
    Key? key,
    required this.username,
    required this.qrCodeUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EnterOtpController _controller = EnterOtpController();

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF2F3F4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, //
        title: Text(
          'Xác minh OTP',
          style: TextStyle(fontSize: 28, color: Color(0xFFEF4D2D)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: const Text(
                  "Vui lòng nhập mã code trong Google Authenticator của bạn",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: Color(0xFFEF4D2D)),
                  ),
                ),
                onCompleted: (pin) {
                  print(
                      'Gửi xác thực OTP với username: $username và OTP: $pin');
                  // Gọi hàm kiểm tra OTP từ controller
                  _controller.verifyOtp(context, username, pin);
                },
              ),
              const SizedBox(height: 10),
              const Text('Quét mã QR trong ứng dụng Google Authenticator'),
              const SizedBox(height: 10),
              qrCodeUrl.isNotEmpty
                  ? Column(
                      children: [
                        QrImageView(
                          data: qrCodeUrl,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
