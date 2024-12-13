import 'package:app/services/api_service.dart';

class OrderFoodController {
  // Lấy danh sách món ăn
  static Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    try {
      List<Map<String, dynamic>> data = await ApiService().fetchOder();

      List<Map<String, dynamic>> menuItems = data
          .map((item) => {
                'item_id': item['item_id'],
                'item_name': item['item_name'],
                'item_price': item['item_price'],
                'item_status': item['item_status']
              })
          .toList();

      return menuItems;
    } catch (e) {
      throw Exception('Error fetching menu items: $e');
    }
  }

  // Hàm thêm món ăn
  static Future<bool> addFoodItem(String itemName, double itemPrice) async {
    try {
      bool success = await ApiService().addFood(itemName, itemPrice);
      return success;
    } catch (e) {
      rethrow;
    }
  }

  
}
