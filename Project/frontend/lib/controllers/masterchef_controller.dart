import 'package:app/services/api_service.dart';

class MasterchefController {
  /// Lấy danh sách món theo bàn
  static Future<List<dynamic>> getOrdersByTable(String tableName) async {
    try {
      return await ApiService().fetchOrdersByTable(tableName);
    } catch (e) {
      print('Error in getOrdersByTable: $e');
      throw Exception('Unable to get orders by table.');
    }
  }

  /// Lấy danh sách tất cả món ăn đang chờ (Pending)
  Future<List<dynamic>> getAllPendingOrders() async {
    try {
      return await ApiService().fetchAllPendingOrders();
    } catch (e) {
      print('Error in getAllPendingOrders: $e');
      throw Exception('Unable to get all pending orders.');
    }
  }
}
