import 'package:app/models/order.dart';
import 'package:app/services/api_service.dart';

class OrderFoodController {
  // Lấy danh sách món ăn
  static ApiService apiService = ApiService();
  static Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    try {
      List<Map<String, dynamic>> data = await ApiService().fetchOrder();

      List<Map<String, dynamic>> menuItems = data
          .map((item) => {
                'item_id': item['item_id'],
                'item_name': item['item_name'],
                'item_price': item['item_price'],
                'item_price_formatted': item[
                    'item_price_formatted'], // Nếu có trường này trong dữ liệu
                'item_describe': item['item_describe'], // Nếu có mô tả món ăn
                'item_status': item['item_status'],
                'item_type': item[
                    'item_type'], // Đảm bảo rằng item_type có trong dữ liệu
              })
          .toList();

      return menuItems;
    } catch (e) {
      print('Error fetching menu items: $e'); // In lỗi ra console
      throw Exception('Error fetching menu items: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchOrdersByTable(
      String tableName) async {
    try {
      final response = await ApiService().fetchOrdersByTable(tableName);

      // ignore: unnecessary_null_comparison
      if (response != null) {
        return response
            .map<Map<String, dynamic>>((order) => {
                  'id': order['id'],
                  'item_name': order['item_name'],
                  'quantity': order['quantity'],
                  'item_price': order['item_price'],
                  'type': order['type'],
                  'status': order['status'],
                  'describe': order['describe'],
                  'timestamp': order['timestamp'], // thời gian món được gọi
                })
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching orders by table: $e');
      throw Exception('Error fetching orders by table: $e');
    }
  }

  // Hàm thêm món ăn
  static Future<bool> addFoodItem(String itemName, double itemPrice,
      String itemDescribe, int itemType, int itemStatus, int restaurant) async {
    try {
      bool success = await ApiService().addFood(
          itemName, itemPrice, itemDescribe, itemType, itemStatus, restaurant);
      return success;
    } catch (e) {
      rethrow;
    }
  }

  // Thêm món ăn vào API
  static Future<void> addOrderItem(Map<String, dynamic> item) async {
    try {
      await ApiService().createOrder(item);
    } catch (e) {
      print('Error adding order item: $e');
      throw Exception('Error adding order item: $e');
    }
  }

  static List<Map<String, dynamic>> buildItems(
      List<Map<String, dynamic>> selectedItems) {
    return selectedItems.map((item) {
      return {
        'item_name': item['item_name'],
        'quantity': item['quantity'],
        'item_price': item['item_price'],
      };
    }).toList();
  }

  // Xây dựng đối tượng `Order` từ thông tin màn hình (sử dụng cho mục đích gửi đơn tổng)
  static Order buildOrder({
    required String tableName,
    required String selectedType,
    required int guestCount,
    required int totalAmount,
    required String type,
    required String describe,
  }) {
    return Order(
      tableName: tableName,
      itemName: selectedType,
      quantity: guestCount,
      itemPrice: totalAmount,
      type: type,
      describe: describe,
      status: 'Pending',
    );
  }

  /// Hàm xóa đơn hàng theo ID
  static Future<void> deleteOrder(int id) async {
    try {
      // Gọi API xóa đơn hàng theo ID
      await ApiService().deleteOrder(id);

      // Nếu thành công
      print('Order with ID $id deleted successfully.');
    } catch (e) {
      // Nếu xảy ra lỗi
      print('Error in OrderController - deleteOrder: $e');
      rethrow; // Tiếp tục ném lỗi để xử lý ở màn hình gọi hàm
    }
  }

  // Xóa tất cả các bản ghi order của một bàn
  static Future<void> clearOrdersByTable(String tableName) async {
    try {
      await ApiService().deleteOrdersByTable(tableName);
    } catch (e) {
      print('Error clearing orders for table $tableName: $e');
      throw Exception('Error clearing orders for table $tableName');
    }
  }

  // Kiểm tra xem bàn có món Buffet hay không
  static Future<bool> hasBuffet(String tableName) async {
    try {
      return await ApiService().checkBuffetStatus(tableName);
    } catch (e) {
      print('Error in OrderFoodController.hasBuffet: $e');
      throw Exception('Error checking buffet status for table $tableName');
    }
  }

  static Future<void> upgradeBuffet(String tableName) async {
    final String url = '${apiService.baseUrl}/orders/upgrade-buffet/';

    try {
      final response = await ApiService().patch(url, {"table_name": tableName});
      if (response.statusCode != 200) {
        throw Exception('Failed to upgrade buffet');
      }
      print('Buffet upgraded successfully');
    } catch (e) {
      print('Error in upgradeBuffet: $e');
      throw Exception('Unable to upgrade buffet for table $tableName');
    }
  }

  static Future<void> transferOrders({
    required String oldTableName,
    required String newTableName,
  }) async {
    final String url = '${apiService.baseUrl}/orders/transfer/';

    try {
      final response = await ApiService().patch(url, {
        "old_table_name": oldTableName,
        "new_table_name": newTableName,
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to transfer orders');
      }
    } catch (e) {
      print('Error in transferOrders: $e');
      throw Exception('Unable to transfer orders');
    }
  }

  static Future<void> checkAndUpdateTableStatus(String tableName) async {
    try {
      // Tạo một instance của ApiService
      ApiService apiService = ApiService();

      // Kiểm tra xem bàn có món không
      bool hasOrders = await apiService.checkTableHasOrders(tableName);

      // Cập nhật trạng thái bàn dựa trên kết quả
      await ApiService().updateTableStatus(tableName, hasOrders);
    } catch (e) {
      print('Error in checkAndUpdateTableStatus: $e');
      throw Exception('Unable to check and update table status');
    }
  }

  static Future<bool> checkTableStatus(String tableName) async {
    try {
      // Tạo một instance của ApiService
      ApiService apiService = ApiService();

      // Kiểm tra xem bàn có món không
      bool hasOrders = await apiService.checkTableHasOrders(tableName);
      return hasOrders;
    } catch (e) {
      print('Error in checkAndUpdateTableStatus: $e');
      throw Exception('Unable to check and update table status');
    }
  }

  /// Lấy danh sách món theo bàn
  static Future<List<dynamic>> getOrdersByTable(String tableName) async {
    try {
      return await ApiService().fetchOrdersByTable(tableName);
    } catch (e) {
      print('Error in getOrdersByTable: $e');
      throw Exception('Unable to get orders by table.');
    }
  }

  /// Gọi API để đánh dấu món ăn là "Served"
  static Future<void> markOrderAsServed(int orderId) async {
    try {
      await ApiService().markOrderAsServed(orderId);
    } catch (e) {
      throw Exception('Failed to mark order as served: $e');
    }
  }

  // Gửi danh sách tất cả món ăn
  static Future<void> sendOrderItems({
    required String tableName,
    Map<String, dynamic>? buffet,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      Map<String, dynamic> data = {
        'table_name': tableName,
        'buffet': buffet,
        'items': items,
      };
      await ApiService().addMultipleOrderItems(data);
    } catch (e) {
      print('Error in sendOrderItems: $e');
      throw Exception('Failed to send order items.');
    }
  }
}
