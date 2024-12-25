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
        title: const Text('Món Ăn Đã Gọi'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("Không có món ăn nào đang chờ xử lý"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Expanded(
                                child: Text("Tên món",
                                    textAlign: TextAlign.center,
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
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey))),
                            Expanded(
                                child: Text("Thao tác",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey))),
                          ],
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        separatorBuilder: (context, index) => const Divider(
                          thickness: 1, // Độ dày đường kẻ
                          color: Colors.grey, // Màu đường kẻ
                        ),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0), // Cách dòng
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                    child: Text(order['item_name'],
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    child: Text(order['table_name'],
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    child: Text(order['quantity'].toString(),
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    child: Text(order['type'] ?? '',
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    child: Text(formatTime(order['timestamp']),
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    child: Text(order['describe'] ?? '',
                                        textAlign: TextAlign.center)),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Hiển thị thông báo tạm thời khi bấm nút "Hủy"
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Đã bấm nút Hủy'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );

                                          // Logic xử lý khi nhấn Hủy (tạm thời để trống)
                                          _cancelOrder(order['id']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text(
                                          'Hủy',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Hiển thị thông báo tạm thời khi bấm nút "Ra món"
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Đã bấm nút Ra món'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );

                                          // Logic xử lý khi nhấn Ra món (tạm thời để trống)
                                          _markOrderAsServed(order['id']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: const Text(
                                          'Ra món',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
