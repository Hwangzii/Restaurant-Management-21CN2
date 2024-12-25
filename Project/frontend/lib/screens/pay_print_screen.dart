import 'dart:convert';

import 'package:app/controllers/pay_controller.dart';
import 'package:app/controllers/tables_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/controllers/oder_food_controller.dart';
import 'package:intl/intl.dart';

class PayPrintScreen extends StatefulWidget {
  final String tableName;
  final int buffetTotal;

  const PayPrintScreen({
    Key? key,
    required this.tableName,
    this.buffetTotal = 0,
  }) : super(key: key);

  @override
  _PayPrintScreenState createState() => _PayPrintScreenState();
}

class _PayPrintScreenState extends State<PayPrintScreen> {
  List<Map<String, dynamic>> orderItems = [];
  bool isLoading = true;

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

  void _showPaymentPopup() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController discountController = TextEditingController();
        String paymentMethod = 'Tiền mặt'; // Default payment method
        String discountType = 'Số tiền'; // Default discount type
        ValueNotifier<int> totalAfterDiscount =
            ValueNotifier(_calculateTotal());

        return StatefulBuilder(
          builder: (context, setState) {
            void updateTotal() {
              int discount = int.tryParse(discountController.text) ?? 0;
              int calculatedTotal = _calculateTotal();

              if (discountType == 'Phần trăm') {
                discount = (calculatedTotal * discount / 100).round();
              }

              totalAfterDiscount.value = (calculatedTotal - discount < 0)
                  ? 0
                  : (calculatedTotal - discount);
            }

            return AlertDialog(
              title: Text(
                'Thanh Toán - Bàn ${widget.tableName}',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: totalAfterDiscount,
                    builder: (context, value, child) {
                      return Text(
                        'Tổng tiền: $value vnđ',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phương thức',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                            DropdownButton<String>(
                              isExpanded: true,
                              value: paymentMethod,
                              onChanged: (String? newValue) {
                                setState(() {
                                  paymentMethod = newValue!;
                                });
                              },
                              items: <String>[
                                'Tiền mặt',
                                'Chuyển khoản'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Loại giảm giá',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                            DropdownButton<String>(
                              isExpanded: true,
                              value: discountType,
                              onChanged: (String? newValue) {
                                setState(() {
                                  discountType = newValue!;
                                  updateTotal(); // Cập nhật tổng tiền khi đổi loại giảm giá
                                });
                              },
                              items: <String>[
                                'Số tiền',
                                'Phần trăm'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nhập giảm giá',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      updateTotal(); // Cập nhật tổng tiền khi nhập giảm giá
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    int finalTotal = totalAfterDiscount.value;

                    // Gọi xác nhận thanh toán
                    bool confirm =
                        await _confirmPayment(finalTotal, paymentMethod);
                    if (confirm) {
                      try {
                        // Tạo hóa đơn
                        final success = await PayController.createInvoice({
                          "list_item": jsonEncode(orderItems.map((item) {
                            return {
                              "item_name": item['item_name'],
                              "quantity": item['quantity'],
                              "price": item['item_price'],
                            };
                          }).toList()), // Chuyển đổi thành chuỗi JSON
                          "total_amount": finalTotal,
                          "payment_method": paymentMethod,
                          "invoice_type": 1,
                          "table_name": widget.tableName,
                          "pre_sale_price": _calculateTotal(),
                          "created_at": DateTime.now()
                              .toIso8601String(), // Thêm thời gian tạo hóa đơn
                        });

                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tạo hóa đơn thất bại!')),
                          );
                          return;
                        }

                        // Xóa order sau khi tạo hóa đơn thành công
                        await OrderFoodController.clearOrdersByTable(
                            widget.tableName);
                        await TablesController.checkAndUpdateTableStatus(
                            widget.tableName);

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Thanh toán thành công!')),
                        );
                        Navigator.pop(context); // Quay lại màn hình trước
                      } catch (e) {
                        print('Error during payment: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Thanh toán thất bại!')),
                        );
                      }
                    }
                  },
                  child: Text('Xác Nhận'),
                ),
              ],
            );
          },
        );
      },
    );
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

  int _calculateTotal() {
    int orderTotal = orderItems.fold(0, (sum, item) {
      int quantity = item['quantity'] ?? 0;
      int price = item['item_price'] ?? 0;
      return sum + (quantity * price);
    });

    // Cộng thêm giá trị Buffet
    return orderTotal; //+ widget.buffetTotal
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
                                    content:
                                        Text('Đã xóa món ${item['item_name']}')),
                              );
                            } catch (e) {
                              print('Error deleting item: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Xóa thất bại!')),
                              );
                            }
                          },
                          child: Container(
                            margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${item['item_price'] * item['quantity']} đ',
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
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Image.asset(
                                            item['status'] == 'Processed'
                                                ? 'assets/check.png' // Hình ảnh cho trạng thái đã xử lý
                                                : 'assets/clock.png', // Hình ảnh cho trạng thái đang xử lý
                                            width: 12, // Chiều rộng hình ảnh
                                            height: 12, // Chiều cao hình ảnh
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
                        );
                      },
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sử dụng Flexible để giới hạn kích thước của Text
                      Flexible(
                        child: Text(
                          'Tổng tiền: ${_calculateTotal()} đ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow
                              .ellipsis, // Thêm để xử lý tràn văn bản
                        ),
                      ),
                      SizedBox(width: 10), // Khoảng cách giữa Text và Button
                      ElevatedButton(
                        onPressed: _showPaymentPopup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Text('Thanh toán'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
