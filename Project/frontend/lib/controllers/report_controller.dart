import 'package:intl/intl.dart';
import 'package:app/services/api_service.dart';

class ReportController {
  final ApiService _apiService;

  ReportController(this._apiService);

  // Hàm định dạng ngày tháng
  String formatCreatedAt(String createdAt) {
    try {
      DateTime dateTime = DateTime.parse(createdAt);
      return DateFormat('dd/MM').format(dateTime);  // Thay đổi để khớp với định dạng UI
    } catch (e) {
      throw Exception('Lỗi khi định dạng ngày tháng: $e');
    }
  }

  Future<Map<String, double>> fetchMonthlyRevenue() async {
  try {
    // Lấy dữ liệu từ API
    List<Map<String, dynamic>> response = await _apiService.fetchInvoiceData();

    Map<String, double> revenueByMonth = {};

    // Duyệt qua dữ liệu và tính tổng doanh thu theo tháng
    for (var invoice in response) {
      try {
        String createdAt = invoice['created_at'] ?? '';
        double totalAmount = double.tryParse(invoice['total_amount']?.toString() ?? '0') ?? 0.0;
        if (createdAt.isEmpty || totalAmount <= 0) {
          continue;
        }

        DateTime dateTime = DateTime.parse(createdAt);
        String formattedMonth = DateFormat('MM/yyyy').format(dateTime); // Định dạng tháng/năm

        revenueByMonth[formattedMonth] = (revenueByMonth[formattedMonth] ?? 0) + totalAmount;
      } catch (e) {
        print('Lỗi khi xử lý hóa đơn: $e, invoice: $invoice');
      }
    }

    return revenueByMonth;
  } catch (e) {
    throw Exception('Lỗi khi xử lý dữ liệu hóa đơn theo tháng: $e');
  }
}


  // Hàm để lấy dữ liệu invoice_food từ API và lọc ra 7 ngày gần nhất từ selectedDate
  Future<Map<String, double>> fetchRevenueReportForSelectedDate(DateTime selectedDate) async {
    try {
      // Lấy dữ liệu từ API
      List<Map<String, dynamic>> response = await _apiService.fetchInvoiceData();

      Map<String, double> revenueByDate = {};

      // Duyệt qua dữ liệu và tính tổng doanh thu theo ngày
      for (var invoice in response) {
        try {
          String createdAt = invoice['created_at'] ?? '';
          double totalAmount = double.tryParse(invoice['total_amount']?.toString() ?? '0') ?? 0.0;
          if (createdAt.isEmpty || totalAmount <= 0) {
            continue;
          }

          String formattedDate = formatCreatedAt(createdAt);
          revenueByDate[formattedDate] = (revenueByDate[formattedDate] ?? 0) + totalAmount;
        } catch (e) {
          print('Lỗi khi xử lý hóa đơn: $e, invoice: $invoice');
        }
      }

      // Lấy 7 ngày gần nhất từ selectedDate
      List<String> daysAroundSelectedDate = [];
      for (int i = 6; i >= 0; i--) {
        DateTime targetDay = selectedDate.subtract(Duration(days: i));
        String formattedDate = DateFormat('dd/MM').format(targetDay); // Sử dụng định dạng dd/MM
        if (revenueByDate.containsKey(formattedDate)) {
          daysAroundSelectedDate.add(formattedDate);
        }
      }

      // Tạo một Map chỉ chứa dữ liệu cho 7 ngày gần nhất từ selectedDate
      Map<String, double> last7DaysData = {};
      for (var day in daysAroundSelectedDate) {
        last7DaysData[day] = revenueByDate[day]!;
      }

      return last7DaysData;
    } catch (e) {
      throw Exception('Lỗi khi xử lý dữ liệu hóa đơn: $e');
    }
  }
}

