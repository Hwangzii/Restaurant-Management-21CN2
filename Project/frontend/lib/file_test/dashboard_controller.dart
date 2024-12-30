import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:app/file_test/dash_board_page.dart';

class DashboardController {
  final String apiUrl =
      'http://457f-14-232-55-213.ngrok-free.app/api/invoice_food/';

  Future<List<BarChartData>> fetchInvoiceData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Xử lý dữ liệu API
      List<BarChartData> barChartData = [];
      Map<DateTime, int> groupedData = {};

      for (var item in data) {
        DateTime date = DateTime.parse(item['created_at']).toLocal();
        date = DateTime(date.year, date.month, date.day); // Chỉ lấy phần ngày

        int totalAmount = int.parse(item['total_amount']);

        if (groupedData.containsKey(date)) {
          groupedData[date] = groupedData[date]! + totalAmount;
        } else {
          groupedData[date] = totalAmount;
        }
      }

      // Chuyển Map thành List<BarChartData>
      barChartData = groupedData.entries
          .map((entry) => BarChartData(date: entry.key, value: entry.value))
          .toList();

      return barChartData;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
