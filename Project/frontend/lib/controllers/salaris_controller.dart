import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class SalariesController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _salaries = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get salaries => _salaries;
  bool get isLoading => _isLoading;

  Future<void> fetchSalaries() async {
    _isLoading = true;
    notifyListeners();
    try {
      _salaries = await _apiService.fetchSalaries();
    } catch (e) {
      print("Error fetching salaries: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thanh toán tất cả các bản ghi lương
  Future<List<dynamic>> payAllSalaries(
      {String paymentMethod = 'Tiền mặt'}) async {
    try {
      final invoices =
          await _apiService.createAllInvoices(paymentMethod: paymentMethod);
      return invoices; // Trả về danh sách hóa đơn đã tạo
    } catch (e) {
      print("Error paying all salaries: $e");
      throw Exception("Failed to pay all salaries");
    }
  }

  /// Lấy danh sách lương theo tháng và năm
  Future<List<Map<String, dynamic>>> getSalariesByMonth(
      int month, int year) async {
    try {
      return await _apiService.fetchSalariesWithMonth(month, year);
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách lương: $e');
    }
  }
}
