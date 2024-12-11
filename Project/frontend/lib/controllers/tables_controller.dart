import 'package:app/services/api_service.dart';

class TablesController {
  // Lấy danh sách bàn theo tầng
  static Future<List<Map<String, dynamic>>> fetchTables(int floor) async {
    try {
      List<Map<String, dynamic>> data = await ApiService().fetchTables();

      List<Map<String, dynamic>> tables = data
          .where((table) => table['floor'] == floor)
          .map((table) => {
                'table_id': table['table_id'],
                'table_name': table['table_name'],
                'floor': table['floor']
              })
          .toList();

      return tables;
    } catch (e) {
      throw Exception('Error fetching tables: $e');
    }
  }

  // Hàm cập nhật tên bàn
  static Future<bool> updateTableName(int tableId, String newName) async {
    try {
      bool success = await ApiService().updateTableName(tableId, newName);
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
}
