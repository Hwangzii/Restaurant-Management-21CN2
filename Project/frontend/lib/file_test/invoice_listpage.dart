import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Mô hình dữ liệu cho hóa đơn
class Invoice {
  final int invoiceFoodId;
  final List<Map<String, dynamic>> listItem;
  final String totalAmount;
  final String paymentMethod;
  final String createdAt;
  final String preSalePrice;
  final String tableName;

  Invoice({
    required this.invoiceFoodId,
    required this.listItem,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    required this.preSalePrice,
    required this.tableName,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var list = json['list_item'] as String;
    List<Map<String, dynamic>> listItem = List<Map<String, dynamic>>.from(
        jsonDecode(list).map((x) => Map<String, dynamic>.from(x)));

    return Invoice(
      invoiceFoodId: json['invoice_food_id'] ?? 0, // Sử dụng giá trị mặc định nếu null
      listItem: listItem,
      totalAmount: json['total_amount'] ?? '', // Sử dụng giá trị mặc định nếu null
      paymentMethod: json['payment_method'] ?? '', // Sử dụng giá trị mặc định nếu null
      createdAt: json['created_at'] ?? '', // Sử dụng giá trị mặc định nếu null
      preSalePrice: json['pre_sale_price'] ?? '', // Sử dụng giá trị mặc định nếu null
      tableName: json['table_name'] ?? '', // Sử dụng giá trị mặc định nếu null
    );
  }
}


// Lớp giao diện chính
class InvoiceListPage extends StatefulWidget {
  @override
  _InvoiceListPageState createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  // Future để lấy dữ liệu từ API
  late Future<List<Invoice>> invoiceData;

  @override
  void initState() {
    super.initState();
    invoiceData = fetchInvoiceData(); // Gọi hàm lấy dữ liệu API khi màn hình được khởi tạo
  }

  // Hàm để lấy dữ liệu từ API
  Future<List<Invoice>> fetchInvoiceData() async {
    final response = await http.get(Uri.parse('https://7944-14-232-55-213.ngrok-free.app/api/invoice_food'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((invoice) => Invoice.fromJson(invoice)).toList();
    } else {
      throw Exception('Failed to load invoice data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Invoice List')),
      body: FutureBuilder<List<Invoice>>(
        future: invoiceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Chờ dữ liệu
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Hiển thị lỗi
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available')); // Không có dữ liệu
          } else {
            // Hiển thị danh sách
            final invoices = snapshot.data!;
            return ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];

                return ListTile(
                  title: Text('Invoice ID: ${invoice.invoiceFoodId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Table: ${invoice.tableName}'),
                      Text('Payment Method: ${invoice.paymentMethod}'),
                      Text('Created At: ${invoice.createdAt}'),
                      Text('Total Amount: ${invoice.totalAmount}'),
                      Text('Pre Sale Price: ${invoice.preSalePrice}'),
                    ],
                  ),
                  onTap: () {
                    // Bạn có thể thêm hành động khi người dùng nhấn vào item
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
