import 'package:app/services/api_service.dart';

class TablesController {
  static ApiService apiService = ApiService();
  // Lấy danh sách bàn theo tầng
  static Future<List<Map<String, dynamic>>> fetchTables(int floor) async {
    try {
      List<Map<String, dynamic>> data = await ApiService().fetchTables();

      List<Map<String, dynamic>> tables = data
          .where((table) => table['floor'] == floor)
          .map((table) => {
                'table_id': table['table_id'],
                'table_name': table['table_name'],
                'floor': table['floor'],
                'status': table['status']
              })
          .toList();

      return tables;
    } catch (e) {
      throw Exception('Error fetching tables: $e');
    }
  }

  // Hàm thêm bàn
  static Future<bool> addTable(String tableName, int floor) async {
    try {
      bool success = await ApiService().addTable(tableName, floor);
      return success;
    } catch (e) {
      rethrow;
    }
  }

  // Hàm sửa bàn
  static Future<bool> updateTableName(
      int tableId, String newName, int floor) async {
    try {
      bool success =
          await ApiService().updateTableName(tableId, newName, floor);
      return success;
    } catch (e) {
      throw Exception('Error updating table name: $e');
    }
  }

  // Hàm xóa bàn
  static Future<bool> deleteTable(int tableId) async {
    try {
      bool success = await ApiService().deleteTable(tableId);
      return success;
    } catch (e) {
      throw Exception('Error deleting table: $e');
    }
  }

  static Future<void> checkAndUpdateTableStatus(String tableName) async {
    try {
      // Tạo một instance của ApiService
      ApiService apiService = ApiService();

      // Kiểm tra xem bàn có món không
      bool hasOrders = await apiService.checkTableHasOrders(tableName);

      // Cập nhật trạng thái bàn dựa trên kết quả
      await apiService.updateTableStatus(tableName, hasOrders);
    } catch (e) {
      print('Error in checkAndUpdateTableStatus: $e');
      throw Exception('Unable to check and update table status');
    }
  }

  // Cập nhật trạng thái cho tất cả bàn
  static Future<void> updateAllTableStatuses() async {
    try {
      ApiService apiService = ApiService();
      await apiService.updateAllTableStatus();
      print('All table statuses updated successfully.');
    } catch (e) {
      print('Error in updateAllTableStatuses: $e');
    }
  }
}
