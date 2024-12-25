import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Lưu `restaurant_id` vào SharedPreferences
  static Future<void> saveRestaurantId(int restaurantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('restaurant_id', restaurantId);
  }

  // Lấy `restaurant_id` từ SharedPreferences
  static Future<int?> getRestaurantId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('restaurant_id');
  }
}
