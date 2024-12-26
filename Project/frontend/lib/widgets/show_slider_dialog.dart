import 'package:flutter/material.dart';

void showSliderDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _SliderDialog();  // Tạo một StatefulWidget cho Dialog
    },
  );
}

class _SliderDialog extends StatefulWidget {
  @override
  __SliderDialogState createState() => __SliderDialogState();
}

class __SliderDialogState extends State<_SliderDialog> {
  double sliderValue = 0;  // Giá trị mặc định ban đầu là 0

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(  // Căn giữa tiêu đề
        child: Text("Chọn phần trăm"),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 300,  // Điều chỉnh chiều rộng của thanh slider
            child: Slider(
              value: sliderValue,
              min: 0,
              max: 100,
              divisions: 20, // 100 / 5 = 20 bước (chia đều 5%)
              label: "${sliderValue.round()}%",
              activeColor: Colors.orange,  // Màu của phần thanh trượt đang được chọn
              inactiveColor: Colors.orange.withOpacity(0.3),  // Màu của phần thanh trượt không được chọn (có độ mờ)
              onChanged: (double value) {
                setState(() {
                  sliderValue = value;  // Cập nhật giá trị của slider khi thay đổi
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
          },
          child: Text("Hủy"),
        ),
        TextButton(
          onPressed: () {
            print("Giá trị đã chọn: ${sliderValue.round()}%");  // In giá trị slider đã chọn
            Navigator.of(context).pop(); // Đóng dialog
          },
          child: Text("OK"),
        ),
      ],
    );
  }
}
