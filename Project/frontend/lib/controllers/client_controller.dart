import 'package:app/services/api_service.dart';

class ClientController {
  static ApiService apiService = ApiService();

  // Hàm lấy danh sách khách hàng theo tên và số điện thoại
  static Future<List<Map<String, dynamic>>> fetchCustomers(
      String customerName, String phoneNumber) async {
    try {
      List<Map<String, dynamic>> customers = await apiService.fetchCustomers();

      return customers.where((customer) {
        // Kiểm tra nếu tên và số điện thoại không phải null trước khi gọi toLowerCase
        bool matchesName = (customer['customer_name'] ?? '')
            .toLowerCase()
            .contains(customerName.toLowerCase());
        bool matchesPhone = (customer['phone_number'] ?? '')
            .toLowerCase()
            .contains(phoneNumber.toLowerCase());

        return matchesName && matchesPhone;
      }).toList();
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }

  // Hàm thêm khách hàng mới
  static Future<bool> addCustomer(String customerName, String phoneNumber,
      int counts, int restaurantId) async {
    try {
      // Gọi ApiService để thêm khách hàng
      bool success = await apiService.addCustomer(
          customerName, phoneNumber, counts, restaurantId);
      return success;
    } catch (e) {
      rethrow; // Nếu có lỗi, ném lại exception
    }
  }

  // Hàm sửa thông tin khách hàng
  static Future<bool> updateCustomer(int customerId, String customerName,
      String phoneNumber, int counts, int restaurantId) async {
    try {
      // Gọi ApiService để cập nhật khách hàng
      bool success = await apiService.updateCustomer(
          customerId, customerName, phoneNumber, counts, restaurantId);
      return success;
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  // Hàm xóa khách hàng
  static Future<bool> deleteCustomer(int customerId) async {
    try {
      bool success = await apiService.deleteCustomer(customerId);
      return success;
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }
}
