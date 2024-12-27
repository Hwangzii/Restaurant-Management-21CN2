import 'dart:async';

import 'package:app/controllers/masterchef_controller.dart';
import 'package:app/controllers/oder_food_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MasterchefScreen extends StatefulWidget {
  const MasterchefScreen({Key? key}) : super(key: key);

  @override
  _MasterchefScreenState createState() => _MasterchefScreenState();
}

class _MasterchefScreenState extends State<MasterchefScreen> {
  final MasterchefController _controller = MasterchefController();
  List<Map<String, dynamic>> orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _controller
          .getAllPendingOrders(); // Fetch orders via controller
      setState(() {
        orders = data.map((order) => Map<String, dynamic>.from(order)).toList();
      });
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelOrder(int orderId) async {
    try {
      // Gọi API để hủy món
      await OrderFoodController.deleteOrder(orderId);

      // Cập nhật giao diện sau khi hủy món
      setState(() {
        orders.removeWhere((order) => order['id'] == orderId);
      });

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Món đã được hủy thành công!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error canceling order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể hủy món! Vui lòng thử lại.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _markOrderAsServed(int orderId) async {
    try {
      await OrderFoodController.markOrderAsServed(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Món đã được phục vụ thành công!')),
      );

      // Xóa món khỏi danh sách
      setState(() {
        orders.removeWhere((order) => order['id'] == orderId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Không thể đánh dấu món là "Ra món"! Vui lòng thử lại.')),
      );
    }
  }

  /// Định dạng thời gian chỉ lấy giờ
  String formatTime(String dateTimeString) {
    try {
      // Chuyển đổi chuỗi thời gian từ API thành đối tượng DateTime
      DateTime dateTime = DateTime.parse(dateTimeString);

      // Sử dụng DateFormat để lấy giờ (HH:mm)
      String formattedTime = DateFormat('HH:mm').format(dateTime);
      return formattedTime;
    } catch (e) {
      print('Error formatting time: $e');
      return ''; // Trả về chuỗi rỗng nếu có lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text('Món Ăn Đã Gọi')],
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Biểu tượng reload
            tooltip: 'Tải lại', // Gợi ý khi hover
            onPressed: () async {
              await _fetchOrders(); // Gọi hàm tải lại dữ liệu
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Danh sách đã được tải lại!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("Không có món ăn nào đang chờ xử lý"))
              : Column(
                  children: [
                    // Header cố định
                    Container(
                      color: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Expanded(
                              child: Text("Tên món",
                                  style: TextStyle(color: Colors.grey))),
                          Expanded(
                              child: Text("Bàn",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey))),
                          Expanded(
                              child: Text("Số lượng",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey))),
                          Expanded(
                              child: Text("Loại vé",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey))),
                          Expanded(
                              child: Text("Thời gian",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey))),
                          Expanded(
                              child: Text("Ghi chú",
                                  style: TextStyle(color: Colors.grey))),
                          Expanded(
                              child: Text("Thao tác",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey))),
                        ],
                      ),
                    ),
                    // Danh sách món cuộn
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Divider(
                                    color: Colors
                                        .grey[300], // Màu sắc của đường kẻ
                                    thickness: 1, // Độ dày của đường kẻ
                                    indent: 4, // Khoảng cách từ bên trái
                                    endIndent: 4, // Khoảng cách từ bên phải
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          child: Text(
                                        order['item_name'],
                                      )),
                                      Expanded(
                                          child: Text(order['table_name'],
                                              textAlign: TextAlign.center)),
                                      Expanded(
                                          child: Text(
                                              order['quantity'].toString(),
                                              textAlign: TextAlign.center)),
                                      Expanded(
                                          child: Text(order['type'] ?? '',
                                              textAlign: TextAlign.center)),
                                      Expanded(
                                          child: Text(
                                              formatTime(order['timestamp']),
                                              textAlign: TextAlign.center)),
                                      Expanded(
                                          child: Text(
                                        order['describe'] ?? '',
                                      )),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                _cancelOrder(order['id']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text(
                                                'Hủy',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _markOrderAsServed(order['id']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              child: const Text(
                                                'Ra món',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
