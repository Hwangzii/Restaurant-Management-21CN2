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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          margin: const EdgeInsets.only(top: 40),
          width: double.infinity,
          child: Column(
            children: [
              qrCodeUrl.isNotEmpty
                  ? Column(
                      children: [
                        QrImageView(
                          data: qrCodeUrl,
                          version: QrVersions.auto,
                          size: 300.0,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                            'Quét mã QR trong ứng dụng Google Authenticator'),
                      ],
                    )
                  : Container(),
              const SizedBox(height: 20),
              const Text(
                "Xác minh",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: Colors.orange),
                  ),
                ),
                onCompleted: (pin) {
                  print(
                      'Gửi xác thực OTP với username: $username và OTP: $pin');
                  // Gọi hàm kiểm tra OTP từ controller
                  _controller.verifyOtp(context, username, pin);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
