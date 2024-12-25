import 'package:flutter/material.dart';

class InvoiceData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String dateTime;

  InvoiceData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.dateTime,
  });
}

final List<InvoiceData> invoiceDataList = [
  InvoiceData(
    icon: Icons.arrow_upward,
    title: "Bán hàng",
    subtitle: "Mã đơn hàng ABC123",
    amount: "+2,000,000",
    dateTime: "24/12/2024 12:05",
  ),
  InvoiceData(
    icon: Icons.arrow_downward,
    title: "Mua nguyên liệu",
    subtitle: "Hóa đơn số DEF456",
    amount: "-1,500,000",
    dateTime: "23/12/2024 14:20",
  ),
  InvoiceData(
    icon: Icons.arrow_upward,
    title: "Dịch vụ",
    subtitle: "Phiếu thu GHI789",
    amount: "+500,000",
    dateTime: "22/12/2024 10:15",
  ),
  InvoiceData(
    icon: Icons.arrow_downward,
    title: "Thanh toán tiền điện",
    subtitle: "Mã hóa đơn JKL012",
    amount: "-200,000",
    dateTime: "21/12/2024 16:30",
  ),
  InvoiceData(
    icon: Icons.arrow_upward,
    title: "Tiền hoa hồng",
    subtitle: "Nhân viên A nhận tiền",
    amount: "+1,000,000",
    dateTime: "20/12/2024 09:00",
  ),
  InvoiceData(
    icon: Icons.arrow_downward,
    title: "Thuê nhân công",
    subtitle: "Nhân viên B làm thêm giờ",
    amount: "-700,000",
    dateTime: "19/12/2024 17:45",
  ),
  InvoiceData(
    icon: Icons.arrow_upward,
    title: "Hoàn tiền khách hàng",
    subtitle: "Mã đơn hàng MNO345",
    amount: "+100,000",
    dateTime: "18/12/2024 11:10",
  ),
  InvoiceData(
    icon: Icons.arrow_downward,
    title: "Đầu tư cơ sở vật chất",
    subtitle: "Mua bàn ghế mới",
    amount: "-3,000,000",
    dateTime: "17/12/2024 13:25",
  ),
  InvoiceData(
    icon: Icons.arrow_upward,
    title: "Chi phí vận chuyển",
    subtitle: "Hóa đơn PQR678",
    amount: "+400,000",
    dateTime: "16/12/2024 15:50",
  ),
  InvoiceData(
    icon: Icons.arrow_downward,
    title: "Quảng cáo",
    subtitle: "Chiến dịch Google Ads",
    amount: "-2,500,000",
    dateTime: "15/12/2024 08:20",
  ),
  // Add more entries as needed (total 30 entries)
];

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Nút quay lại
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        title: Stack(
          children: [
            Align(
              alignment: Alignment.center, // Căn giữa tiêu đề
              child: Text(
                'Thông tin hóa đơn',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true, // Đảm bảo Stack hoạt động đúng
        backgroundColor: Colors.white, // Màu nền AppBar
      ),

      body: ListView.builder(
        itemCount: invoiceDataList.length,
        itemBuilder: (context, index) {
          final item = invoiceDataList[index];
          return ListTile(
            leading: Icon(item.icon, color: item.amount.startsWith('+') ? Colors.green : Colors.red),
            title: Text(item.title),
            subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.amount, style: TextStyle(color: item.amount.startsWith('+') ? Colors.green : Colors.red)),
                Text(item.dateTime, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: InvoiceScreen(),
  ));
}
