import 'package:app/screens/bill_screen.dart';
import 'package:app/screens/manager_screen.dart';
import 'package:app/screens/tables_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:app/models/user.dart';
import 'package:intl/intl.dart';

class PaymentSuccessfulScreen extends StatefulWidget {
  final User user;
  const PaymentSuccessfulScreen({Key? key, required this.user})
      : super(key: key);

  @override
  State<PaymentSuccessfulScreen> createState() =>
      _PaymentSuccessfulScreenState();
}

class _PaymentSuccessfulScreenState extends State<PaymentSuccessfulScreen> {
  // Biến trạng thái để điều khiển vị trí container
  bool _isVisible = false;
  late Future<Map<String, dynamic>> invoiceDataFuture;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Kích hoạt animation sau khi màn hình được hiển thị
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });
    });
    // Lấy dữ liệu hóa đơn từ API và gán vào future
    invoiceDataFuture = _loadInvoiceData(); // Thay đổi thành Future
  }

  // Hàm lấy dữ liệu hóa đơn
  Future<Map<String, dynamic>> _loadInvoiceData() async {
    try {
      return await apiService.getLatestInvoice();
    } catch (e) {
      // Xử lý lỗi khi không lấy được dữ liệu
      print('Lỗi: $e');
      return {}; // Trả về một map rỗng nếu gặp lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF45211), // Nền đỏ
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future:
              invoiceDataFuture, // Sử dụng FutureBuilder với invoiceDataFuture
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có dữ liệu'));
            }

            final invoiceData = snapshot.data!;
            // Lấy thông tin từ invoiceData
            final tableName = invoiceData['table_name'];
            final createdAt = DateFormat('HH:mm - dd/MM/yyyy')
                .format(DateTime.parse(invoiceData['created_at']));
            final salePercent = invoiceData['sale_percent'];
            final preSalePrice = NumberFormat('#,###')
                .format(int.parse(invoiceData['pre_sale_price']));
            String paymentMethod = invoiceData['payment_method'];
            final totalAmount = NumberFormat('#,###')
                .format(int.parse(invoiceData['total_amount']));

            return AnimatedContainer(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(
                top: _isVisible
                    ? MediaQuery.of(context).size.height * 0.0
                    : MediaQuery.of(context).size.height,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/correct.png',
                          height: 100.0,
                          width: 100.0,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 20.0),
                        const Text(
                          'Thanh toán thành công',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Text(
                          '+ $totalAmount VNĐ',
                          style: TextStyle(
                            fontSize: 28.0,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 35.0),
                        buildInfoRow('Bàn ăn', tableName),
                        buildInfoRow('Thời gian', createdAt),
                        buildInfoRow('Khuyến mãi', '$salePercent%'),
                        buildInfoRow('Giá gốc', '$preSalePrice VNĐ'),
                        buildInfoRow('Loại thanh toán', '$paymentMethod'),
                        const SizedBox(height: 30.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TablesScreen(
                                          user: widget.user,
                                        )));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF45211),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            minimumSize: const Size(double.infinity, 50.0),
                          ),
                          child: const Text(
                            'Tiếp tục bán hàng',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget hiển thị một hàng trong bảng thông tin
  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn trái và phải
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.grey, // Text bên phải màu xám
            ),
          ),
        ],
      ),
    );
  }
}
