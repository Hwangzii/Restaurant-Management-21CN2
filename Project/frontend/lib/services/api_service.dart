import 'package:app/file_test/invoice_listpage.dart';
import 'package:app/models/item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class ApiService {
  final String baseUrl =
      'https://457f-14-232-55-213.ngrok-free.app/api'; // Cập nhật URL API của bạn

  // Gửi request đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    final loginUrl = '$baseUrl/login/';

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'is2faEnabled': data['is_2fa_enabled'], // Check if 2FA is enabled
          'qrCodeUrl':
              data['qr_code_url'], // If 2FA enabled, return QR Code URL
        };
      } else {
        return {'success': false};
      }
    } catch (e) {
      print('Error calling API: $e');
      return {'success': false};
    }
  }

  // Gửi request xác thực OTP
  Future<Map<String, dynamic>> verifyOtp(String username, String otp) async {
    final verifyOtpUrl = '$baseUrl/verify_otp/';

    try {
      final response = await http.post(
        Uri.parse(verifyOtpUrl),
        body: {'username': username, 'otp': otp},
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false};
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return {'success': false};
    }
  }

  Future<Map<String, dynamic>> getRestaurantByAccountId(int accountId) async {
    // Giả sử bạn sử dụng HTTP để gọi API
    final response =
        await http.get(Uri.parse('$baseUrl/restaurant/$accountId'));

    if (response.statusCode == 200) {
      return json
          .decode(response.body); // Giả sử API trả về thông tin restaurant
    } else {
      throw Exception('Failed to load restaurant');
    }
  }

  // Hàm lấy dữ liệu bàn từ API
  Future<List<Map<String, dynamic>>> fetchTables() async {
    final tablesUrl = '$baseUrl/tables/'; // Đường dẫn API lấy danh sách bàn

    try {
      final response = await http.get(Uri.parse(tablesUrl), headers: {
        'Accept': 'application/json', // Đảm bảo yêu cầu JSON
        "ngrok-skip-browser-warning": "69420",
      });

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      throw Exception('Error fetching tables: $e');
    }
  }

  // Hàm thêm bàn
  Future<bool> addTable(String tableName, int floor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tables/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'table_name': tableName, 'floor': floor}),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  // Hàm sửa bàn
  Future<bool> updateTableName(int tableId, String newName, int floor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tables/$tableId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'table_name': newName, 'floor': floor}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  // Cập nhật trạng thái bàn
  Future<void> updateTableStatus(String tableName, bool hasOrders) async {
    final String url = '$baseUrl/tables/update-status/$tableName/';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': hasOrders ? 1 : 0}),
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update table status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateTableStatus: $e');
      throw Exception('Error updating table status for $tableName');
    }
  }

  // hàm chung gian
  Future<http.Response> patch(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      print('Error in ApiService.patch: $e');
      throw Exception('Failed to send PATCH request to $url');
    }
  }

  // Kiểm tra trạng thái Buffet
  Future<Map<String, dynamic>> checkBuffetStatus(String tableName) async {
    final String url = '$baseUrl/orders/has-buffet?table_name=$tableName';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Giải mã dữ liệu phản hồi với utf8
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedResponse);

        // Trả về Map chứa cả trạng thái và tên Buffet (nếu có)
        return {
          "has_buffet": data['has_buffet'] ?? false,
          "buffet_name": data['buffet_name'] ?? "Tất cả",
        };
      } else {
        throw Exception(
            'Failed to check buffet status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in ApiService.checkBuffetStatus: $e');
      // Trả về mặc định nếu lỗi xảy ra
      return {"has_buffet": false, "buffet_name": "Tất cả"};
    }
  }

  // Cập nhật tất cả trạng thái bàn
  Future<void> updateAllTableStatus() async {
    final String url = '$baseUrl/tables/update-all-status/';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update all table statuses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateAllTableStatus: $e');
      throw Exception('Error updating all table statuses');
    }
  }

  //Hàm xóa bàn
  Future<bool> deleteTable(int tableId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tables/$tableId/'),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  // Hàm lấy danh sách món ăn
  Future<List<Map<String, dynamic>>> fetchOrder() async {
    final orderUrl = '$baseUrl/menu_items/'; // Đường dẫn lấy API menu

    try {
      final response = await http.get(Uri.parse(orderUrl), headers: {
        'Accept': 'application/json; charset=UTF-8',
        "ngrok-skip-browser-warning":
            "69420", // Nếu bạn sử dụng ngrok cho môi trường phát triển
      });

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(decodedResponse);
        return List<Map<String, dynamic>>.from(data);
      } else {
        // Nếu mã trạng thái không phải 200, ném lỗi và in thông tin chi tiết
        throw Exception(
            'Lỗi khi tải danh sách món ăn. Mã trạng thái: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý ngoại lệ nếu có lỗi khi lấy dữ liệu
      throw Exception('Lỗi khi lấy dữ liệu món ăn: $e');
    }
  }

  // Hàm thêm món ăn
  Future<bool> addFood(String itemName, double itemPrice, String itemDescribe,
      int itemType, int itemStatus, int restaurant) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu_items/'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'item_name': itemName,
          'item_price': itemPrice.toString(), // Chuyển giá thành chuỗi
          'item_price_formatted': itemPrice
              .toStringAsFixed(3)
              .replaceAll('.', ','), // Định dạng giá
          'item_describe': itemDescribe,
          'item_type': itemType,
          'item_status': itemStatus, // Trạng thái món ăn (mặc định có sẵn)
          'restaurant': restaurant, // ID nhà hàng (mặc định)
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        // Trả về true nếu thành công
        return true;
      } else {
        // Nếu không thành công, in thông tin chi tiết của phản hồi
        print('Server Response: ${response.body}');
        throw Exception(
            'Lỗi khi thêm món ăn. Mã trạng thái: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý lỗi trong quá trình gửi yêu cầu POST
      throw Exception('Lỗi khi thêm món ăn: $e');
    }
  }

  // Hàm lấy danh sách kho
  Future<List<Item>> getItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/items/'),
      headers: {
        'Accept': 'application/json; charset=UTF-8',
        "ngrok-skip-browser-warning": "69420",
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      List jsonResponse = json.decode(decodedResponse);
      return jsonResponse.map((item) => Item.fromJson(item)).toList();
    } else {
      throw Exception(
          'Lỗi khi tải danh sách. Mã trạng thái: ${response.statusCode}');
    }
  }

  // Hàm tạo item mới trong kho
  Future<void> createItem(Item item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create item');
    }
  }

  // Hàm sửa item trong kho
  Future<void> updateItem(Item item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/items/${item.itemId}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item');
    }
  }

  // Hàm xóa item trong kho
  Future<void> deleteItem(int id) async {
    final deleteUrl = '$baseUrl/menu_items/'; // Đường dẫn lấy API menu
    final response = await http.delete(
      Uri.parse('$deleteUrl/items/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item');
    }
  }

  // Hàm lấy dữ liệu nhân viên từ API
  Future<List<Map<String, dynamic>>> fetchEmployees() async {
    final tablesUrl = '$baseUrl/employees/'; // Đường dẫn API lấy danh sách nhân viên

    try {
      final response = await http.get(Uri.parse(tablesUrl), headers: {
        'Accept': 'application/json; charset=UTF-8', // Đảm bảo yêu cầu JSON
        "ngrok-skip-browser-warning": "69420",
      });

      if (response.statusCode == 200) {
        // Giải mã UTF-8
        final decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(decodedResponse);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("Error fetching employees: ${response.statusCode} ${response.reasonPhrase}");
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      print("Error fetching employees: $e");
      throw Exception('Error fetching employees: $e');
    }
  }

   //Hàm thêm nhân viên
  Future<bool> addEmployee({
    required String fullName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String address,
    required String position,
    required DateTime timeStart,
    required String cccd,
    required int restaurant,
  }) async {
    final url = '$baseUrl/employees/';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'full_name': fullName,
          'phone_number': phoneNumber,
          'date_of_birth': DateFormat('yyyy-MM-dd')
              .format(dateOfBirth), // Chuyển đổi DateTime thành chuỗi
          'employees_address': address,
          'position': position,
          'time_start': DateFormat('yyyy-MM-dd')
              .format(timeStart), // Chuyển đổi DateTime thành chuỗi
          'cccd': cccd,
          'restaurant': restaurant,
          // 'created_at': DateTime.now().toIso8601String(),
          // 'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        print('Employee added successfully!');
        return true;
      } else {
        print('Server Response: ${response.body}');
        throw Exception(
            'Failed to add employee. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding employee: $e');
      return false;
    }
  }

  // Hàm sửa thông tin nhân viên
  Future<bool> updateEmployee({
    required int employeeId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      // Thêm timestamp cập nhật vào dữ liệu
      updatedData['updated_at'] = DateTime.now().toIso8601String();

      // Kiểm tra và định dạng các trường ngày nếu có
      if (updatedData.containsKey('date_of_birth')) {
        DateTime dob = DateTime.parse(updatedData['date_of_birth']);
        updatedData['date_of_birth'] = DateFormat('yyyy-MM-dd').format(dob);
      }

      if (updatedData.containsKey('time_start')) {
        DateTime ts = DateTime.parse(updatedData['time_start']);
        updatedData['time_start'] = DateFormat('yyyy-MM-dd').format(ts);
      }

      // Kiểm tra định dạng số điện thoại nếu được cập nhật
      if (updatedData.containsKey('phone_number')) {
        final phoneRegex = RegExp(r'^\d{10,15}$');
        if (!phoneRegex.hasMatch(updatedData['phone_number'])) {
          throw Exception('Số điện thoại không hợp lệ.');
        }
      }

      // Kiểm tra định dạng CCCD nếu được cập nhật
      if (updatedData.containsKey('cccd')) {
        final cccdRegex = RegExp(r'^\d{9,12}$');
        if (!cccdRegex.hasMatch(updatedData['cccd'])) {
          throw Exception('CCCD không hợp lệ.');
        }
      }

      final response = await http.put(
        Uri.parse('$baseUrl/employees/$employeeId/'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Đã cập nhật nhân viên thành công!');
        return true;
      } else {
        print('Phản hồi từ server: ${response.body}');
        throw Exception(
            'Lỗi khi cập nhật nhân viên. Mã trạng thái: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi cập nhật nhân viên: $e');
      return false;
    }
  }

  // Hàm xóa nhân viên
  Future<bool> deleteEmployee(int employeeId) async {
    final url = '$baseUrl/employees/$employeeId/';
    try {
      // Có thể thêm xác nhận từ người dùng ở đây nếu cần

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 204) {
        print('Đã xóa nhân viên thành công!');
        return true;
      } else {
        print('Phản hồi từ server: ${response.body}');
        throw Exception(
            'Không thể xóa nhân viên. Mã trạng thái: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi xóa nhân viên: $e');
      return false;
    }
  }


  // Hàm gọi API để lấy danh sách lịch làm việc
  Future<List<Map<String, dynamic>>> fetchWorkSchedules() async {
    final scheduleUrl = '$baseUrl/work_schedule/'; // Đường dẫn API lấy lịch làm việc

    try {
      final response = await http.get(Uri.parse(scheduleUrl), headers: {
        'Accept': 'application/json; charset=UTF-8', // Đảm bảo yêu cầu JSON
        "ngrok-skip-browser-warning": "69420",
      });

      if (response.statusCode == 200) {
        // Giải mã UTF-8
        final decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(decodedResponse);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("Error fetching work schedules: ${response.statusCode} ${response.reasonPhrase}");
        throw Exception('Failed to load work schedules');
      }
    } catch (e) {
      print("Error fetching work schedules: $e");
      throw Exception('Error fetching work schedules: $e');
    }
  }

  //Hàm gọi API lưu ca làm 
  Future<void> saveWorkSchedules(List<Map<String, dynamic>> shifts) async {
  for (var shift in shifts) {
    try {
      // Gửi từng ca làm qua API
      final response = await http.post(
        Uri.parse('$baseUrl/work_schedule/'),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: jsonEncode(shift),  // Chuyển shift thành JSON
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Giả sử bạn có thể lấy trạng thái từ response của API để gán vào status
        String status = shift['is_on_time'] == true ? 'có' : 'muộn';
        
        // Bạn có thể gán giá trị status vào dữ liệu hoặc lưu lại để sử dụng
        print("Ca làm đã lưu thành công với trạng thái: $status");
        
        // Ví dụ nếu shift có lý do nghỉ
        if (shift['absence_reason'] != null && shift['absence_reason'].isNotEmpty) {
          status = 'nghỉ có phép';
        } else if (status.isEmpty) {
          status = 'nghỉ không phép';
        }

        // Tiến hành lưu vào hệ thống hoặc cập nhật UI sau khi lưu thành công
      } else {
        print("Lỗi khi lưu ca làm: ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối hoặc xử lý: $e");
    }
  }
}

// Hàm lấy danh sách lương
  Future<List<Map<String, dynamic>>> fetchSalaries() async {
    final salariesUrl = '$baseUrl/salaries/'; // Đường dẫn API lấy danh sách lương

    try {
      final response = await http.get(Uri.parse(salariesUrl), headers: {
        'Accept': 'application/json; charset=UTF-8', // Đảm bảo yêu cầu JSON
        "ngrok-skip-browser-warning": "69420", // Nếu sử dụng ngrok
      });

      if (response.statusCode == 200) {
        // Giải mã UTF-8 để xử lý dữ liệu chứa ký tự đặc biệt
        final decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(decodedResponse);
        return List<Map<String, dynamic>>.from(data); // Chuyển đổi về dạng danh sách Map
      } else {
        print(
            "Error fetching salaries: ${response.statusCode} ${response.reasonPhrase}");
        throw Exception('Failed to load salaries');
      }
    } catch (e) {
      print("Error fetching salaries: $e");
      throw Exception('Error fetching salaries: $e');
    }
  }

  // Hàm thêm order_item
  Future<void> createOrder(Map<String, dynamic> order) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(order),
      );

      // In thông báo lỗi nếu API trả về mã khác ngoài 201
      if (response.statusCode != 201) {
        print('API Response: ${response.body}'); // In chi tiết lỗi từ API
        throw Exception('Failed to create order');
      }
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Error creating order: $e');
    }
  }

  //Hàm sửa order_item
  Future<void> updateOrder(int id, Map<String, dynamic> order) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$id/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(order),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update order');
    }
  }

  // Hàm xóa đơn hàng theo ID
  Future<void> deleteOrder(int id) async {
    final url = Uri.parse('$baseUrl/orders/$id/');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode != 204) {
        // 204: No Content
        print('API Response: ${response.body}');
        throw Exception('Failed to delete order');
      }
    } catch (e) {
      print('Error deleting order: $e');
      throw Exception('Error deleting order: $e');
    }
  }

  // Hàm xóa tất cả order theo table_name
  Future<void> deleteOrdersByTable(String tableName) async {
    final url = Uri.parse('$baseUrl/orders/clear/?table_name=$tableName');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete orders for table $tableName');
    }
  }

  // Kiểm tra bàn có món hay không
  Future<bool> checkTableHasOrders(String tableName) async {
    final url = Uri.parse('$baseUrl/orders/getcheck/?table_name=$tableName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['has_orders'];
    } else {
      throw Exception('Failed to check table status: ${response.statusCode}');
    }
  }

  // Hàm lấy danh order_item theo bàn
  Future<List<dynamic>> fetchOrdersByTable(String tableName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/?table_name=$tableName'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    } else {
      throw Exception('Failed to fetch orders for table $tableName');
    }
  }

  // Hàm để lấy dữ liệu invoice_food
  Future<List<Map<String, dynamic>>> fetchInvoiceData() async {
    final invoiceUrl =
        '$baseUrl/invoice_food/'; // Đường dẫn API lấy danh sách lương

    try {
      final response = await http.get(Uri.parse(invoiceUrl), headers: {
        'Accept': 'application/json; charset=UTF-8', // Đảm bảo yêu cầu JSON
        "ngrok-skip-browser-warning": "69420", // Nếu sử dụng ngrok
      });

      if (response.statusCode == 200) {
        // Giải mã UTF-8 để xử lý dữ liệu chứa ký tự đặc biệt
        final decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(decodedResponse);
        return List<Map<String, dynamic>>.from(
            data); // Chuyển đổi về dạng danh sách Map
      } else {
        print(
            "Error fetching invoice: ${response.statusCode} ${response.reasonPhrase}");
        throw Exception('Failed to load invoice');
      }
    } catch (e) {
      print("Error fetching invoice: $e");
      throw Exception('Error fetching invoice: $e');
    }
  }

  // Gọi API để đánh dấu món ăn là "Served"
  Future<void> markOrderAsServed(int orderId) async {
    final String url = '$baseUrl/orders/$orderId/mark-as-served/';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to mark order as served: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking order as served: $e');
    }
  }

  // Gửi danh sách tất cả món ăn
  Future<void> addMultipleOrderItems(Map<String, dynamic> data) async {
    final String url = '$baseUrl/orders/add-multiple-items/';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add multiple items: ${response.body}');
      }
    } catch (e) {
      print('Error in addMultipleOrderItems: $e');
      throw Exception('Unable to add multiple items.');
    }
  }
  
}


