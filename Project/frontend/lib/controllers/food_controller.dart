import 'dart:convert';
import 'package:app/services/api_service.dart'; // Service API được định nghĩa riêng
import 'package:http/http.dart' as http;


class FoodController {
  FoodController(this._apiService);

final ApiService _apiService;

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
   Future<bool> addFood(
    String itemName,
    double itemPrice,
    String itemDescribe,
    int itemType,
    bool itemStatus,
    int restaurant,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${_apiService.baseUrl}/menu_items/'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'item_name': itemName,
          'item_price': itemPrice.toString(),
          'item_price_formatted': itemPrice.toStringAsFixed(3).replaceAll('.', ','),
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
        throw Exception('Lỗi khi thêm món ăn. Mã trạng thái: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm món ăn: $e');
    }
  }



// Hàm xóa món ăn
Future<void> deleteItem(int id) async {
  try {
    // Xây dựng URL từ ApiService
    final response = await http.delete(
      Uri.parse('${_apiService.baseUrl}/menu_items/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 204) {
      // Ném lỗi nếu trạng thái không phải 204
      throw Exception('Failed to delete item. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    // Log lỗi và ném lại ngoại lệ
    print('Error deleting item: $e');
    throw Exception('Error deleting item: $e');
  }
}

}
