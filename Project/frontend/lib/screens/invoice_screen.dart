import 'package:app/controllers/invoice_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceScreen extends StatefulWidget {
  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  DateTime? selectedDate;
  bool isLoading = false;
  TextEditingController searchController =
      TextEditingController(); // Controller for search
  bool isSearchVisible = false; // Variable to control the search visibility
  List<Map<String, dynamic>> invoices = [];
  final InvoiceController invoiceController = InvoiceController();

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      isLoading = true;
    });
    try {
      await invoiceController.fetchInvoices();
      setState(() {
        invoices = invoiceController.invoices;
      });
    } catch (e) {
      print("Error fetching invoices: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatCurrency(String amount) {
    final number =
        double.tryParse(amount.replaceAll(',', '').replaceAll('đ', '')) ?? 0;
    final format = NumberFormat.simpleCurrency(locale: 'vi_VN');
    return format.format(number);
  }

  String formatDate(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(parsedDate);
    } catch (e) {
      return dateString; // Trả về giá trị gốc nếu không thể định dạng
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredInvoicesData = invoices
        .where((item) => item['invoice_salaries_id']
            .toString()
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false, //
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Back button
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
        title: Stack(
          children: [
            Align(
              alignment: Alignment.center, // Center the title
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
        centerTitle: true, // Ensure Stack works correctly
        backgroundColor: Colors.white, // AppBar background color
      ),
      body: ListView.separated(
        itemCount: filteredInvoicesData.length,
        itemBuilder: (context, index) {
          final item = filteredInvoicesData[index];

          return ListTile(
            leading: item['invoice_type'] == 1
                ? Image.asset(
                    'assets/up.png', // Đường dẫn đến hình ảnh trong assets
                    width: 24,
                    height: 24,
                    color: Colors.green,
                  )
                : Image.asset(
                    'assets/down.png', // Đường dẫn đến hình ảnh trong assets
                    width: 24,
                    height: 24,
                    color: Colors.black,
                  ),
            title: Text('${item['invoice_name']}'), // invoice_food_id
            subtitle: Text(
              '${item['describe']}',
              style: TextStyle(fontSize: 12, color: Color(0xFFABB2B9)),
            ), // sale_percent
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item['invoice_type'] == 1 ? '+' : '-'}${formatCurrency(item['money'].toString())}',
                  style: TextStyle(
                    fontSize: 18,
                    color: item['invoice_type'] == 1
                        ? Colors.green
                        : Colors.black, // Màu tiền
                  ),
                ),
                Text(
                  formatDate(item['created_at']),
                  style: TextStyle(fontSize: 12, color: Color(0xFFABB2B9)),
                ), // payment_method
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.shade300, // Màu đường kẻ
          thickness: 1, // Độ dày
          indent: 16, // Khoảng cách từ lề trái
          endIndent: 16, // Khoảng cách từ lề phải
        ),
      ),
    );
  }
}
