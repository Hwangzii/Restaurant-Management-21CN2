import 'dart:convert';

import 'package:app/controllers/pay_controller.dart';
import 'package:app/controllers/tables_controller.dart';
import 'package:app/models/user.dart';
import 'package:app/screens/payment_successful_screen.dart';
import 'package:app/screens/tables_screen.dart';
import 'package:app/widgets/show_slider_dialog.dart';
import 'package:flutter/material.dart';
import 'package:app/controllers/oder_food_controller.dart';
import 'package:intl/intl.dart';

class PayPrintScreen extends StatefulWidget {
  final String tableName;
  final int buffetTotal;
  final User user;

  const PayPrintScreen({
    Key? key,
    required this.tableName,
    this.buffetTotal = 0,
    required this.user,
  }) : super(key: key);

  @override
  _PayPrintScreenState createState() => _PayPrintScreenState();
}

class _PayPrintScreenState extends State<PayPrintScreen> {
  List<Map<String, dynamic>> orderItems = [];
  bool isLoading = true;
  double selectedPercentage = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrderItems();
  }

  Future<void> _fetchOrderItems() async {
    try {
      final items =
          await OrderFoodController.fetchOrdersByTable(widget.tableName);
      setState(() {
        orderItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading order items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _clearAllOrders() async {
    try {
      // Gọi API xóa tất cả món ăn trong danh sách
      await OrderFoodController.clearOrdersByTable(widget.tableName);
      await TablesController.checkAndUpdateTableStatus(widget.tableName);
      setState(() {
        orderItems.clear(); // Cập nhật giao diện
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa tất cả món ăn thành công!')),
      );
    } catch (e) {
      print('Error clearing orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa tất cả thất bại!')),
      );
    }
  }

  Future<bool> _confirmPayment(
      int totalAfterDiscount, String paymentMethod) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận thanh toán',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Trả về false
            child: Text('Hủy', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Trả về true
            child: Text('Xác nhận', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

// Hàm tính tổng tiền trước chiết khấu
  double _calculateSubtotal() {
    return orderItems.fold(0, (sum, item) {
      int quantity = item['quantity'] ?? 0;
      int price = item['item_price'] ?? 0;
      return sum + (quantity * price);
    });
  }

// Hàm tính tổng tiền sau chiết khấu
  double _calculateTotal() {
    double orderTotal =
        _calculateSubtotal(); // Gọi hàm tính tổng tiền trước chiết khấu
    return orderTotal - orderTotal * (selectedPercentage / 100);
  }

  static Future<void> showPaymentForm(
      BuildContext context,
      String tableName,
      double totalAmount,
      double totalAmount1,
      double selectedPercentage,
      List<Map<String, dynamic>> orderItems,
      User user) async {
    String selectedPaymentMethod = 'Tiền mặt'; // Default payment method
    List<String> paymentMethods = ['Tiền mặt', 'Chuyển khoản'];

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(child: Text('Thanh toán')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hiển thị tên bàn
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tên bàn:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    tableName,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Dropdown chọn phương thức thanh toán
              DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                items: paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    selectedPaymentMethod = value;
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Phương thức thanh toán',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Hiển thị tổng tiền
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giảm giá:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("${selectedPercentage.round()}%",
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng tiền:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    NumberFormat('#,##0', 'vi_VN').format(totalAmount) + 'đ',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Nút hủy
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            // Nút xác nhận
            ElevatedButton(
              onPressed: () async {
                try {
                  // Gọi API để tạo hóa đơn
                  bool success = await PayController.createInvoice({
                    "list_item": jsonEncode(orderItems.map((item) {
                      return {
                        "item_name": item['item_name'],
                        "quantity": item['quantity'],
                        "price": item['item_price'],
                      };
                    }).toList()),
                    "total_amount":
                        totalAmount.round(), // Tổng tiền đã làm tròn
                    "payment_method": selectedPaymentMethod,
                    "invoice_type": 1, // Loại hóa đơn (1 = trực tiếp)
                    "table_name": tableName,
                    "pre_sale_price": totalAmount1.round(),
                    "sale_percent": selectedPercentage.round(),
                    "created_at": DateTime.now().toIso8601String(),
                  });

                  if (success) {
                    // Xóa order sau khi tạo hóa đơn thành công
                    await OrderFoodController.clearOrdersByTable(tableName);
                    await TablesController.checkAndUpdateTableStatus(tableName);

                    Navigator.pop(dialogContext); // Đóng dialog
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentSuccessfulScreen(user: user),
                        ) // Thay `NewScreen` bằng tên màn hình bạn muốn chuyển đến
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thanh toán thành công!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tạo hóa đơn thất bại!')),
                    );
                  }
                } catch (e) {
                  print('Error during payment: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thanh toán thất bại!')),
                  );
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Bo góc dialog
          ),
        );
      },
    );
  }

// Hàm tính tổng số lượng
  int _totalQuantity() {
    return orderItems.fold(0, (sum, item) {
      int quantity = item['quantity'] ?? 0;
      return sum + quantity;
    });
  }

  String _extractTime(String? dateTime) {
    if (dateTime == null) return 'Unknown'; // Xử lý khi giá trị null
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat.Hm()
          .format(parsedDate); // Trả về giờ và phút, ví dụ: "14:30"
    } catch (e) {
      print('Error parsing time: $e');
      return 'Invalid Time'; // Trả về giá trị mặc định nếu có lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Bàn ${widget.tableName}'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all, color: Colors.red),
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Xác nhận xóa tất cả'),
                    content: Text('Bạn có chắc chắn muốn xóa tất cả món ăn?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Xóa'),
                      ),
                    ],
                  );
                },
              );
              if (confirm) {
                _clearAllOrders(); // Xóa toàn bộ món ăn
                await OrderFoodController.checkAndUpdateTableStatus(
                    widget.tableName);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TablesScreen(
                            user: widget.user,
                          )), // Thay `NewScreen` bằng tên màn hình bạn muốn chuyển đến
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Tên món',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF929292)),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'SL',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF929292)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Giá',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF929292)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                // Order List
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        final item = orderItems[index];
                        return Dismissible(
                          key: Key(item['id']
                              .toString()), // Mỗi item phải có một key duy nhất
                          direction: DismissDirection
                              .endToStart, // Vuốt từ phải sang trái
                          background: Container(
                            color: Colors.red, // Màu nền khi vuốt
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            // Hiển thị thông báo xác nhận
                            return await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Xác nhận xóa'),
                                  content: Text(
                                      'Bạn có chắc chắn muốn xóa món "${item['item_name']}" không?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Xóa'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) async {
                            try {
                              // Gọi API xóa item
                              await OrderFoodController.deleteOrder(item['id']);
                              setState(() {
                                orderItems
                                    .removeAt(index); // Xóa item khỏi danh sách
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Đã xóa món ${item['item_name']}')),
                              );
                            } catch (e) {
                              print('Error deleting item: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Xóa thất bại!')),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              Divider(
                                color: Colors.grey[300], // Màu sắc của đường kẻ
                                thickness: 1, // Độ dày của đường kẻ
                                indent: 16, // Khoảng cách từ bên trái
                                endIndent: 16, // Khoảng cách từ bên phải
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['item_name'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  4), // Khoảng cách giữa tên món và thời gian
                                          Text(
                                            _extractTime(item[
                                                'timestamp']), // Hiển thị thời gian
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${item['quantity']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${item['item_price']} đ', //* item['quantity']
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          SizedBox(
                                              height:
                                                  4), // Khoảng cách giữa giá và trạng thái
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              () {
                                                print(
                                                    'Status: ${item['status']}');
                                                return const SizedBox(); // Trả về một widget rỗng để không ảnh hưởng tới giao diện
                                              }(),
                                              Image.asset(
                                                '${item['status']}' == 'Served'
                                                    ? 'assets/check.png' // Hình ảnh cho trạng thái đã xử lý
                                                    : 'assets/clock.png', // Hình ảnh cho trạng thái đang xử lý

                                                width:
                                                    12, // Chiều rộng hình ảnh
                                                height:
                                                    12, // Chiều cao hình ảnh
                                                fit: BoxFit
                                                    .contain, // Điều chỉnh kích thước hình ảnh phù hợp
                                              ),
                                            ],
                                          )
                                        ],
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
                  ),
                ),
              ],
            ),

      // navigator bar
      bottomNavigationBar: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white, // Đặt màu nền cho container
          border: Border(
            top: BorderSide(
                color: Colors.grey.shade300,
                width: 1), // Đường ngăn cách giữa navigator và body
          ),
        ),
        child: Row(
          children: [
            // Phần bên trái với 4 dòng văn bản chiếm 2/3 chiều rộng
            Expanded(
              flex: 2,
              child: _buildTextColumn(),
            ),
            VerticalDivider(
              width: 1,
              color: Colors.grey.shade300, // Đường kẻ mờ ngăn giữa 2 cột
            ),
            // Phần bên phải với 2 button căn giữa chiếm 1/3 chiều rộng
            Expanded(
              flex: 1,
              child: _buildButtonColumn(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextColumn() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text("Vé:",
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("buffet đỏ",
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text("SL:",
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("${_totalQuantity()}",
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text("KM:",
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text("${selectedPercentage.round()}%",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      Spacer(),
                      GestureDetector(
                        onTap: () async {
                          double? result = await showSliderDialog(context);

                          if (result != null) {
                            setState(() {
                              selectedPercentage = result; // Cập nhật giá trị
                            });
                          }
                        },
                        child: Image.asset(
                          'assets/edit-text.png', // Đường dẫn đến hình ảnh thay thế cho icon
                          width: 24, // Kích thước của hình ảnh
                          height: 24, // Kích thước của hình ảnh
                          color: Colors
                              .orange, // Màu sắc nếu cần (có thể bỏ nếu không muốn thay đổi màu)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text("T.Tiền:",
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                      "${_calculateTotal() % 1 == 0 ? _calculateTotal().toInt() : _calculateTotal()} đ",
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonColumn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Button trên màu cam với chiều rộng cố định
          Container(
            width: 150,
            child: ElevatedButton.icon(
              onPressed: () {
                double totalAmount = _calculateTotal();
                double totalAmount1 = _calculateSubtotal();
                showPaymentForm(context, widget.tableName, totalAmount,
                    totalAmount1, selectedPercentage, orderItems, widget.user);
                print("Button 1 pressed");
              },
              label: Text(
                "Thanh toán",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.left,
              ),
              icon: Image.asset(
                'assets/dollar.png',
                width: 16,
                height: 16,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                minimumSize: MaterialStateProperty.all(
                    Size(200, 50)), // Chiều rộng và chiều cao tối thiểu của nút
              ),
            ),
          ),
          SizedBox(height: 10),
          // Button dưới màu xám với chiều rộng cố định
          Container(
            width: 150,
            child: ElevatedButton.icon(
              onPressed: () {
                print("Button 2 pressed");
              },
              label: Text(
                "In hóa đơn",
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.left,
              ),
              icon: Image.asset(
                'assets/print.png',
                width: 16,
                height: 16,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFFF2F2F2)),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                minimumSize: MaterialStateProperty.all(
                    Size(200, 50)), // Chiều rộng và chiều cao tối thiểu của nút
              ),
            ),
          ),
        ],
      ),
    );
  }
}
