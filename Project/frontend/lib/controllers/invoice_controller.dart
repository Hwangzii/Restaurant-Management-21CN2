import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class InvoiceController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get invoices => _invoices;
  bool get isLoading => _isLoading;

  Future<void> fetchInvoices() async {
    _isLoading = true;
    notifyListeners();
    try {
      _invoices = await _apiService.fetchInvoiceData();
    } catch (e) {
      print("Error fetching invoices: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
