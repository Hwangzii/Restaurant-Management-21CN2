import 'package:app/models/item.dart';
import 'package:app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class ApiService {
  final String baseUrl =
      'https://520c-42-114-170-0.ngrok-free.app/api'; // Cập nhật URL API của bạn

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
        final data = json.decode(response.body);
        return {
          'success': true,
          "restaurant_id": data['restaurant_id'],
          "role": data['role'],
          "password": data['password']
        };
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
    final response = await http.delete(
      Uri.parse('$baseUrl/items/$id/'),
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
    final tablesUrl =
        '$baseUrl/employees/'; // Đường dẫn API lấy danh sách nhân viên

    try {
      final response = await http.get(Uri.parse(tablesUrl), headers: {
        'Accept': 'application/json; charset=UTF-8', // Đảm bảo yêu cầu JSON
        "ngrok-skip-browser-warning": "69420",
      });

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(decodedResponse);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      throw Exception('Error fetching tables: $e');
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
    final scheduleUrl =
        '$baseUrl/work_schedule/'; // Đường dẫn API lấy lịch làm việc

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
        print(
            "Error fetching work schedules: ${response.statusCode} ${response.reasonPhrase}");
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
          body: jsonEncode(shift), // Chuyển shift thành JSON
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Giả sử bạn có thể lấy trạng thái từ response của API để gán vào status
          String status = shift['is_on_time'] == true ? 'có' : 'muộn';

          // Bạn có thể gán giá trị status vào dữ liệu hoặc lưu lại để sử dụng
          print("Ca làm đã lưu thành công với trạng thái: $status");

          // Ví dụ nếu shift có lý do nghỉ
          if (shift['absence_reason'] != null &&
              shift['absence_reason'].isNotEmpty) {
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

  // Gửi yêu cầu cập nhật trạng thái dựa trên employee_id và shift_type
  Future<http.Response> postUpdateStatusByEmployee(
      int employeeId, String shiftType, String newStatus) async {
    final url = Uri.parse("$baseUrl/work_schedule/update-status-by-employee/");
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'employee_id': employeeId,
        'shift_type': shiftType,
        'status': newStatus,
      }),
    );
  }

  // Gửi yêu cầu cập nhật trạng thái dựa trên employee_id và shift_type
  Future<http.Response> postreasonByEmployee(
      int employeeId, String shiftType, String reason) async {
    final url = Uri.parse("$baseUrl/work_schedule/update-reason-by-employee/");
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'employee_id': employeeId,
        'shift_type': shiftType,
        'reason': reason,
      }),
    );
  }

// Hàm lấy danh sách lương
  Future<List<Map<String, dynamic>>> fetchSalaries() async {
    final salariesUrl =
        '$baseUrl/salaries/'; // Đường dẫn API lấy danh sách lương

    try {
      final response = await http.get(Uri.parse(salariesUrl), headers: {
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
            "Error fetching salaries: ${response.statusCode} ${response.reasonPhrase}");
        throw Exception('Failed to load salaries');
      }
    } catch (e) {
      print("Error fetching salaries: $e");
      throw Exception('Error fetching salaries: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSalariesWithMonth(
      int month, int year) async {
    final url =
        Uri.parse('$baseUrl/salaries/?salary_month=$month&salary_year=$year');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode dữ liệu UTF-8
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(utf8DecodedBody);

      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Lỗi khi gọi API: ${response.statusCode}');
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

  /// Lấy danh sách tất cả món ăn đang chờ (Pending)
  Future<List<dynamic>> fetchAllPendingOrders() async {
    final String url = '$baseUrl/orders/list-chef/';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Giải mã body thành UTF-8 trước khi xử lý JSON
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        return data; // Trả về danh sách món ăn đang Pending
      } else {
        throw Exception(
            'Failed to fetch pending orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchAllPendingOrders: $e');
      throw Exception('Unable to fetch all pending orders.');
    }
  }

  /// Gọi API để đánh dấu món ăn là "Served"
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

  // Lấy danh sách sản phẩm
  Future<List<dynamic>> getSanPham() async {
    final response = await http.get(Uri.parse('$baseUrl/work_schedule/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load sản phẩm');
    }
  }

  // API: Thanh toán tất cả các bản ghi lương
  Future<List<dynamic>> createAllInvoices(
      {String paymentMethod = 'Tiền mặt'}) async {
    final url = Uri.parse('$baseUrl/salaries/create-all-invoices/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'payment_method': paymentMethod}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body); // Trả về danh sách hóa đơn
    } else {
      throw Exception('Failed to create invoices: ${response.body}');
    }
  }

  // Hàm thay đổi mật khẩu
  Future<bool> changePassword(
      int userId, String oldPassword, String newPassword) async {
    final String userUrl =
        '$baseUrl/accounts/$userId/'; // URL để lấy thông tin người dùng
    final String updateUrl =
        '$baseUrl/accounts/$userId/'; // URL để cập nhật thông tin

    try {
      // 1. Lấy thông tin người dùng hiện tại
      final userResponse = await http.get(
        Uri.parse(userUrl),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);

        // 2. Chuẩn bị dữ liệu cho yêu cầu PUT
        final Map<String, dynamic> requestBody = {
          "username": userData["username"],
          "password": newPassword, // Thay đổi mật khẩu
          // "name": userData["name"],
          // "user_phone": userData["user_phone"],
          // "email": userData["email"],
          // "role": userData["role"],
          // "restaurant_id": userData["restaurant_id"],
        };

        // 3. Gửi yêu cầu PUT để cập nhật mật khẩu
        final updateResponse = await http.put(
          Uri.parse(updateUrl),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode(requestBody),
        );

        if (updateResponse.statusCode == 200) {
          print('Mật khẩu đã được thay đổi thành công');
          return true;
        } else {
          print(
              'Lỗi khi thay đổi mật khẩu: ${updateResponse.statusCode} - ${updateResponse.body}');
          return false;
        }
      } else {
        print(
            'Lỗi khi lấy thông tin người dùng: ${userResponse.statusCode} - ${userResponse.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi: $e');
      return false;
    }
  }

  // Hàm lấy dữ liệu khách hàng từ API
  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final customersUrl =
        '$baseUrl/customers/'; // Đường dẫn API lấy danh sách khách hàng

    try {
      final response = await http.get(Uri.parse(customersUrl), headers: {
        'Accept': 'application/json; charset=UTF-8', // Đảm bảo yêu cầu JSON
        "ngrok-skip-browser-warning": "69420",
      });

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(decodedResponse);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Failed to load customers: ${response.body}');
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      print('Error fetching customers: $e');
      throw Exception('Error fetching customers: $e');
    }
  }

  // Hàm API thêm khách hàng
  Future<bool> addCustomer(String customersName, String phoneNumber, int counts,
      int restaurantId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_name': customersName,
          'phone_number': phoneNumber,
          'counts': counts, // Thêm counts
          'restaurant': 2, // Thêm restaurantId
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add customer: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding customer: $e');
      return false;
    }
  }

  // Hàm API sửa khách hàng
  Future<bool> updateCustomer(int customerId, String customerName,
      String phoneNumber, int counts, int restaurantId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/customers/$customerId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_name': customerName,
          'phone_number': phoneNumber,
          'counts': counts,
          'restaurant': 2,
        }),
      );

      // In ra phản hồi để kiểm tra lỗi
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Failed to update customer: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating customer: $e');
      return false;
    }
  }

  // Hàm API xóa khách hàng
  Future<bool> deleteCustomer(int customersId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/customers/$customersId/'),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print('Failed to delete customer: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting customer: $e');
      return false;
    }
  }

  // Hàm để lấy dữ liệu invoice_food
  Future<List<Map<String, dynamic>>> fetchInvoiceData() async {
    final invoiceUrl =
        '$baseUrl/invoice_food/'; // Đường dẫn API lấy danh sách hóa đơn bán hàng
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

  // Hàm để lấy dữ liệu invoice_food
  Future<List<Map<String, dynamic>>> fetchAllInvoiceData() async {
    final invoiceUrl =
        '$baseUrl/invoice/'; // Đường dẫn API lấy danh sách hóa đơn bán hàng
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

  // hàm tính tổng doanh thu
  Future<double> fetchTotalRevenue() async {
    final List<Map<String, dynamic>> invoices = await fetchInvoiceData();
    double totalRevenue = 0;

    for (var invoice in invoices) {
      totalRevenue += double.tryParse(invoice['total_amount'] ?? '0') ?? 0;
    }

    return totalRevenue;
  }

  Future<double> fetchFinancialSummary() async {
    try {
      // Lấy danh sách tất cả hóa đơn từ API
      final List<Map<String, dynamic>> invoices = await fetchAllInvoiceData();

      double totalRevenue = 0; // Tổng doanh thu (type = 1)
      double totalCost = 0; // Tổng chi phí (type = 2 và type = 3)

      for (var invoice in invoices) {
        int invoiceType = invoice['invoice_type'] ?? 0; // Lấy loại hóa đơn
        double money = double.tryParse(invoice['money'].toString()) ?? 0;

        if (invoiceType == 1) {
          // Cộng vào tổng doanh thu
          totalRevenue += money;
        } else if (invoiceType == 2 || invoiceType == 3) {
          // Cộng vào tổng chi phí
          totalCost += money;
        }
      }

      // Tính tổng thu chi (doanh thu - chi phí)
      return totalRevenue - totalCost;
    } catch (e) {
      print('Error fetching financial summary: $e');
      throw Exception('Failed to fetch financial summary');
    }
  }

  Future<double> fetchIncomeGrowthPercentage() async {
    try {
      // Lấy danh sách tất cả hóa đơn từ API
      final List<Map<String, dynamic>> invoices = await fetchAllInvoiceData();

      // Lấy ngày hôm nay và hôm qua
      final DateTime today = DateTime.now();
      final DateTime yesterday = today.subtract(const Duration(days: 1));

      double todayIncome = 0; // Thu nhập hôm nay
      double yesterdayIncome = 0; // Thu nhập hôm qua

      for (var invoice in invoices) {
        int invoiceType = invoice['invoice_type'] ?? 0; // Loại hóa đơn
        double money = double.tryParse(invoice['money'].toString()) ?? 0;

        // Lấy ngày giao dịch từ hóa đơn
        String invoiceDateStr =
            invoice['created_at'] ?? ''; // Định dạng ngày từ API (yyyy-MM-dd)
        DateTime? invoiceDate = DateTime.tryParse(invoiceDateStr);

        if (invoiceDate != null) {
          if (isSameDay(invoiceDate, today)) {
            // Hôm nay
            if (invoiceType == 1) {
              todayIncome += money; // Doanh thu
            } else if (invoiceType == 2 || invoiceType == 3) {
              todayIncome -= money; // Trừ chi phí
            }
          } else if (isSameDay(invoiceDate, yesterday)) {
            // Hôm qua
            if (invoiceType == 1) {
              yesterdayIncome += money; // Doanh thu
            } else if (invoiceType == 2 || invoiceType == 3) {
              yesterdayIncome -= money; // Trừ chi phí
            }
          }
        }
      }

      // Tính tăng trưởng phần trăm
      if (yesterdayIncome == 0) {
        // Tránh chia cho 0
        return todayIncome > 0 ? 100.0 : 0.0;
      }

      return ((todayIncome - yesterdayIncome) / yesterdayIncome) * 100;
    } catch (e) {
      throw Exception('Lỗi khi tính tăng trưởng thu nhập: $e');
    }
  }

// Hàm kiểm tra xem hai ngày có giống nhau không
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<int> countType1Records() async {
    try {
      // Lấy danh sách tất cả hóa đơn từ API
      final List<Map<String, dynamic>> invoices = await fetchAllInvoiceData();

      // Sử dụng hàm đếm
      int count =
          invoices.where((invoice) => invoice['invoice_type'] == 1).length;

      return count; // Trả về số lượng bản ghi type = 1
    } catch (e) {
      throw Exception('Lỗi khi đếm số lượng bản ghi type = 1: $e');
    }
  }

  Future<int> countActiveTables() async {
    try {
      // Lấy danh sách tất cả các bàn từ API
      final List<Map<String, dynamic>> tables = await fetchTables();

      // Sử dụng hàm đếm
      int count = tables.where((table) => table['status'] == true).length;

      return count; // Trả về số lượng bàn có status = 1
    } catch (e) {
      throw Exception('Lỗi khi đếm số bàn có status = 1: $e');
    }
  }

  Future<double> fetchTotalCost() async {
    try {
      // Lấy danh sách tất cả hóa đơn từ API
      final List<Map<String, dynamic>> invoices = await fetchAllInvoiceData();

      double totalCost = 0; // Tổng chi phí (type = 2 và type = 3)

      for (var invoice in invoices) {
        int invoiceType = invoice['invoice_type'] ?? 0; // Lấy loại hóa đơn
        double money = double.tryParse(invoice['money'].toString()) ?? 0;

        if (invoiceType == 2 || invoiceType == 3) {
          // Cộng vào tổng chi phí
          totalCost += money;
        }
      }

      print('Total Cost: $totalCost'); // In ra tổng chi phí cuối cùng
      return totalCost; // Trả về tổng chi phí
    } catch (e) {
      print('Error fetching total cost: $e');
      throw Exception('Failed to fetch total cost');
    }
  }

  // Hàm lấy thông tin tài khoản dựa trên username
  Future<Map<String, dynamic>?> getAccountInfo(String username) async {
    final accountInfoUrl = '$baseUrl/accounts/';

    try {
      final response = await http.get(Uri.parse(accountInfoUrl));

      if (response.statusCode == 200) {
        // Giải mã dữ liệu JSON đảm bảo UTF-8
        final List<dynamic> accounts =
            jsonDecode(utf8.decode(response.bodyBytes));
        // Tìm tài khoản dựa trên username
        final account = accounts.firstWhere(
          (acc) => acc['username'] == username,
          orElse: () => null,
        );

        if (account != null) {
          // Trả về thông tin tài khoản với tên tiếng Việt
          return {
            'success': true,
            'data': {
              'id': account['id'],
              'username': account['username'],
              'password': account['password'],
              'name': account['name'],
              'phone': account['user_phone'],
              'email': account['email'],
              'createdAt': account['created_at'],
            },
          };
        } else {
          return {
            'success': false,
            'message': 'Người dùng không tìm thấy',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Không thể lấy thông tin tài khoản',
        };
      }
    } catch (e) {
      print('Error fetching account info: $e');
      return null;
    }
  }

  /// Lấy danh sách WorkSchedule
  Future<List<dynamic>> getWorkSchedules() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/work_schedule/'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to fetch work schedules: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching work schedules: $e");
    }
  }

  // Hàm lấy thông tin hóa đơn theo invoice_food_id
  Future<Map<String, dynamic>> getLatestInvoice() async {
    final response = await http.get(
      Uri.parse('$baseUrl/invoice_food/'),
      headers: {'Accept-Charset': 'UTF-8'}, // Đảm bảo encoding là UTF-8
    );

    if (response.statusCode == 200) {
      // Ép kiểu UTF-8 nếu cần thiết
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(responseBody);

      if (data.isNotEmpty) {
        // Sắp xếp theo invoice_food_id để lấy hóa đơn mới nhất
        data.sort(
          (a, b) => b['invoice_food_id'].compareTo(a['invoice_food_id']),
        );
        return data[0]; // Trả về hóa đơn mới nhất
      } else {
        throw Exception('Không có dữ liệu hóa đơn');
      }
    } else {
      throw Exception('Lỗi khi tải dữ liệu');
    }
  }

  Future<User> fetchUserData() async {
    try {
      final url = Uri.parse('$baseUrl/accounts/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode dữ liệu từ bytes sang UTF-8
        final utf8DecodedBody = utf8.decode(response.bodyBytes);

        // Parse JSON từ dữ liệu đã decode
        final List<dynamic> data = json.decode(utf8DecodedBody);

        // Kiểm tra danh sách dữ liệu và trả về người dùng đầu tiên
        if (data.isNotEmpty) {
          return User.fromMap(data[0]);
        } else {
          throw Exception('Không có dữ liệu người dùng.');
        }
      } else {
        throw Exception(
            'Lỗi khi tải dữ liệu người dùng: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu người dùng: $e');
    }
  }
}
