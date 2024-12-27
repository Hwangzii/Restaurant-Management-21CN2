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
    final number = double.tryParse(amount.replaceAll(',', '').replaceAll('đ', '')) ?? 0;
    final format = NumberFormat.simpleCurrency(locale: 'vi_VN');
    return format.format(number);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredInvoicesData = invoices
        .where((item) => item['invoice_food_id']
            .toString()
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
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

      body: ListView.builder(
        itemCount: filteredInvoicesData.length,
        itemBuilder: (context, index) {
          final item = filteredInvoicesData[index];

          // Determine amount color based on positive or negative value
          final isPositiveAmount = item['total_amount'].toString().startsWith('+');

          return ListTile(
            leading: Icon(
              isPositiveAmount ? Icons.arrow_upward : Icons.arrow_downward,
              color: isPositiveAmount ? Colors.green : Colors.red,
            ),
            title: Text('${item['invoice_food_id']}'), // invoice_food_id
            subtitle: Text('${item['sale_percent']}', style: TextStyle(fontSize: 12)), // sale_percent
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatCurrency(item['total_amount'].toString()), 
                  style: TextStyle(color: isPositiveAmount ? Colors.green : Colors.red),
                ), // total_amount formatted as currency
                Text('${item['payment_method']}', style: TextStyle(fontSize: 12, color: Colors.grey)), // payment_method
              ],
            ),
          );
        },
      ),
    );
  }
}
