import 'package:app/services/api_service.dart';

class OrderFoodController {
  // Lấy danh sách món ăn
  static Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    try {
      List<Map<String, dynamic>> data = await ApiService().fetchOrder();

      List<Map<String, dynamic>> menuItems = data
          .map((item) => {
                'item_id': item['item_id'],
                'item_name': item['item_name'],
                'item_price': item['item_price'],
                'item_price_formatted': item['item_price_formatted'], // Nếu có trường này trong dữ liệu
                'item_describe': item['item_describe'], // Nếu có mô tả món ăn
                'item_status': item['item_status'],
                'item_type': item['item_type'], // Đảm bảo rằng item_type có trong dữ liệu
              })
          .toList();

      return menuItems;
    } catch (e) {
      print('Error fetching menu items: $e');  // In lỗi ra console
      throw Exception('Error fetching menu items: $e');
    }
  }

  // Hàm thêm món ăn
  static Future<bool> addFoodItem(String itemName, double itemPrice, String itemDescribe, int itemType, bool itemStatus, int restaurant) async {
    try {
      bool success = await ApiService().addFood(itemName, itemPrice, itemDescribe, itemType, itemStatus, restaurant);
      return success;
    } catch (e) {
      rethrow;
    }
  }
}
