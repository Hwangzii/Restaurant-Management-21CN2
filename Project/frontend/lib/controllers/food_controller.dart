import 'dart:convert';
import 'package:app/services/api_service.dart'; // Service API được định nghĩa riêng
import 'package:http/http.dart' as http;

final String baseUrl =
    'https://e5c6-2402-800-61cf-d12-907d-800d-a5b6-c258.ngrok-free.app/api'; // URL API cần được thay bằng URL thực tế

class FoodController {
  // Hàm lấy danh sách món ăn từ API
  static Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    try {
      // Gọi API để lấy dữ liệu
      List<Map<String, dynamic>> data = await ApiService().fetchOrder();

      // Xử lý dữ liệu để trả về danh sách món ăn
      List<Map<String, dynamic>> menuItems = data
          .map((item) => {
                'item_id': item['item_id'],
                'item_name': item['item_name'],
                'item_price': item['item_price'],
                'item_price_formatted': item['item_price_formatted'], // Định dạng giá (nếu có)
                'item_describe': item['item_describe'], // Mô tả món ăn (nếu có)
                'item_status': item['item_status'],
                'item_type': item['item_type'], // Kiểu món ăn
              })
          .toList();

      return menuItems;
    } catch (e) {
      print('Error fetching menu items: $e'); // In lỗi ra console
      throw Exception('Error fetching menu items: $e');
    }
  }

  // Hàm thêm món ăn vào cơ sở dữ liệu thông qua API
  static Future<bool> addFood(
      String itemName,
      double itemPrice,
      String itemDescribe,
      int itemType,
      bool itemStatus,
      int restaurant) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu_items/'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'item_name': itemName,
          'item_price': itemPrice.toString(),
          'item_price_formatted': itemPrice
              .toStringAsFixed(3)
              .replaceAll('.', ','), // Định dạng giá nếu cần
          'item_describe': itemDescribe,
          'item_type': itemType,
          'item_status': itemStatus,
          'restaurant': restaurant,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        print('Thêm món ăn thành công.');
        return true;
      } else {
        print('Server Response: ${response.body}');
        throw Exception(
            'Lỗi khi thêm món ăn. Mã trạng thái: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm món ăn: $e');
    }
  }


// Ham xoa mon an
  static Future<void> deleteItem(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/menu_items/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item');
    }
  }

// // Hàm thêm món ăn
//   static Future<bool> addFoodItem(String itemName, double itemPrice, String itemDescribe, int itemType, int itemStatus, int restaurant) async {
//     try {
//       bool success = await ApiService().addFood(itemName, itemPrice, itemDescribe, itemType, itemStatus, restaurant);
//       return success;
//     } catch (e) {
//       rethrow;
//     }
//   }

  
}
