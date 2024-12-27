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
}
