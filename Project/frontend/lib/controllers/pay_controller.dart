import 'dart:convert';
import 'package:app/services/api_service.dart';
import 'package:http/http.dart' as http;

class PayController {
  static ApiService apiService = ApiService();

  // Phương thức tạo hóa đơn
  static Future<bool> createInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final String url = '${apiService.baseUrl}/invoice_food/';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(invoiceData),
      );

      if (response.statusCode == 201) {
        // Tạo hóa đơn thành công
        return true;
      } else {
        print('Failed to create invoice: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating invoice: $e');
      return false;
    }
  }
}
