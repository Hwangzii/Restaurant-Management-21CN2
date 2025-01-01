import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> invoices; // Danh sách hóa đơn
  final int maxItems; // Số lượng hóa đơn tối đa hiển thị

  InvoiceListWidget({required this.invoices, this.maxItems = 0});

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
    // Nếu maxItems > 0, chỉ lấy maxItems hóa đơn
    final displayedInvoices =
        maxItems > 0 ? invoices.take(maxItems).toList() : invoices;

    return ListView.separated(
      itemCount: displayedInvoices.length,
      itemBuilder: (context, index) {
        final item = displayedInvoices[index];

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
                  fontSize: 14,
                  color: item['invoice_type'] == 1
                      ? Colors.green
                      : Colors.black, // Màu tiền
                ),
              ),
              Text(
                formatDate(item['created_at']),
                style: TextStyle(fontSize: 12, color: Color(0xFFABB2B9)),
              ),
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
    );
  }
}
