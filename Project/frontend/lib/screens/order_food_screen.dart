import 'package:app/controllers/oder_food_controller.dart';
import 'package:app/models/order.dart';
import 'package:app/screens/pay_print_screen.dart';
import 'package:app/widgets/list_order_food.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/food_items.dart';
import 'package:intl/intl.dart';

class OrderFoodScreen extends StatefulWidget {
  final String tableName;
  final String selectedType;
  final int guestCount;

  const OrderFoodScreen({
    super.key,
    required this.tableName,
    required this.selectedType,
    required this.guestCount,
  });

  @override
  State<OrderFoodScreen> createState() => _OrderFoodScreenState();
}

class _OrderFoodScreenState extends State<OrderFoodScreen> {
  TextEditingController searchController = TextEditingController();
  bool _showOverlay = false; // Biến điều khiển hiển thị overlay

  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> selectedItems = []; // Danh sách món đã chọn
  List<Map<String, dynamic>> temporaryOrders = []; // Danh sách đơn gửi bếp
  List<Map<String, dynamic>> currentOrder = []; // Danh sách món hiện tại
  int selectedOption = 0;

  late List<String> options; // Tùy biến options

  @override
  void initState() {
    super.initState();

    // Thiết lập options dựa trên loại món
    if (widget.selectedType.contains('Buffet')) {
      options = ['Thường', 'Cho trẻ em'];
    } else {
      options = ['Tất cả', 'Món chính', 'Đồ uống', 'Buffet đỏ', 'Buffet đen'];
    }

    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      List<Map<String, dynamic>> fetchedItems =
          await OrderFoodController.fetchMenuItems();
      setState(() {
        menuItems = fetchedItems;
        _filterItemsByType();
      });
    } catch (e) {
      print('Error loading menu items: $e');
    }
  }

  void _filterItemsByType() {
    String selectedType = widget.selectedType;
    setState(() {
      if (selectedType == 'Buffet đỏ') {
        filteredItems = menuItems
            .where((item) => item['item_type'] == 3 || item['item_type'] == 5)
            .toList();
      } else if (selectedType == 'Buffet đen') {
        filteredItems = menuItems
            .where((item) => item['item_type'] == 4 || item['item_type'] == 6)
            .toList();
      } else {
        filteredItems = menuItems;
      }
    });
  }

  void _saveOrderAndSendToKitchen() async {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có món nào để gửi!')),
      );
      return;
    }

    String formattedTimestamp =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Tạo danh sách các món ăn từ `selectedItems`
    List<Map<String, dynamic>> items = selectedItems.map((item) {
      return {
        'item_name': item['item_name'],
        'quantity': item['quantity'],
        'item_price': item['item_price'],
      };
    }).toList();

    // Tạo dữ liệu order
    final order = Order(
      tableName: widget.tableName,
      itemName: widget.selectedType, // Có thể thay bằng dữ liệu phù hợp
      quantity: widget.guestCount,
      itemPrice: _calculateTotal(), // Tổng tiền
      status: 'Pending',
    );

    try {
      // Gọi API để lưu đơn hàng
      await OrderFoodController.addOrder(order);

      // Thêm đơn hàng vào danh sách tạm thời
      setState(() {
        temporaryOrders.add({
          'table_name': widget.tableName,
          'order_type': widget.selectedType,
          'guest_count': widget.guestCount,
          'items': items,
          'total_amount': _calculateTotal(),
          'timestamp': formattedTimestamp,
        });

        // Cập nhật danh sách hiện tại và xóa danh sách đã chọn
        currentOrder = List.from(selectedItems);
        selectedItems.clear();
      });

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đơn hàng đã được gửi tới bếp!')),
      );
    } catch (e) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi đơn hàng: $e')),
      );
    }
  }

  void _filterItemsByOption(int option) {
    setState(() {
      if (widget.selectedType.contains('Buffet')) {
        // Lọc món ăn cho Buffet
        if (option == 0) {
          filteredItems = menuItems
              .where((item) => item['item_type'] == 3) // Buffet thường
              .toList();
        } else if (option == 1) {
          filteredItems = menuItems
              .where((item) => item['item_type'] == 5) // Buffet trẻ em
              .toList();
        }
      } else {
        // Lọc món ăn cho Gọi món
        if (option == 0) {
          filteredItems = menuItems.where((item) {
            return item['item_type'] >= 1 && item['item_type'] <= 4;
          }).toList();
        } else {
          int selectedType = option;
          filteredItems = menuItems.where((item) {
            return item['item_type'] == selectedType;
          }).toList();
        }
      }
    });
  }

  int _calculateTotal() {
    return selectedItems.fold(0, (sum, item) {
      try {
        int price = item['item_price'] ?? 0;
        int quantity = item['quantity'] ?? 0;
        return sum + (price * quantity);
      } catch (e) {
        print('Lỗi tính tổng tiền: $e');
        return sum;
      }
    });
  }

  int _calculateTotalItems() {
    try {
      return selectedItems.fold(0, (sum, item) {
        int quantity = item['quantity'] ?? 0;

        if (quantity is! int) {
          print('Lỗi: `quantity` không phải là số nguyên trong $item');
          return sum;
        }

        return sum + quantity;
      });
    } catch (e) {
      print('Lỗi khi tính tổng số lượng món: $e');
      return 0;
    }
  }

  void _showOrderHistory() {
    // Tính tổng tiền của tất cả các đơn hàng
    int totalAmount = temporaryOrders.fold(0, (sum, order) {
      // Kiểm tra xem `total_amount` có tồn tại và là số nguyên hay không
      int orderAmount = order['total_amount'] ?? 0; // Mặc định 0 nếu không có
      if (orderAmount is! int) {
        print(
            'Lỗi: total_amount không phải là số nguyên trong đơn hàng: $order');
        orderAmount = 0; // Đặt lại giá trị an toàn
      }
      return sum + orderAmount;
    });

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Lịch sử đơn hàng',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Expanded(
                  child: temporaryOrders.isEmpty
                      ? Center(
                          child: Text(
                            'Không có lịch sử đơn hàng.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: temporaryOrders.length,
                          itemBuilder: (context, index) {
                            final order = temporaryOrders[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bàn: ${order['table_name']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Thời gian: ${order['timestamp']}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Danh sách món:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // Thêm ListView hoặc Column cho danh sách món ăn
                                    Column(
                                      children:
                                          order['items'].map<Widget>((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  '${item['item_name']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                  overflow: TextOverflow
                                                      .ellipsis, // Xử lý tràn văn bản
                                                ),
                                              ),
                                              Text(
                                                'x${item['quantity']} - ${item['item_price']} đ',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tổng tiền đơn:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${order['total_amount']} đ',
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                Divider(),
                // Hiển thị tổng tiền của tất cả các đơn hàng
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tổng tiền tất cả:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${totalAmount} đ',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('${widget.tableName}',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.orange),
            onPressed: () {
              _showOrderHistory(); // Hiển thị lịch sử đơn hàng
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF2F3F4),
      body: Stack(
        children: [
          Column(
            children: [
              // Thanh tùy chọn
              Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                color: Colors.white,
                height: 35,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = index;
                            _filterItemsByOption(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: selectedOption == index
                                ? Color(0xFFF2F2F2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              options[index],
                              style: TextStyle(
                                fontSize: 13,
                                color: selectedOption == index
                                    ? Color(0xFFFF8A00)
                                    : Color(0xFF929292),
                              ),
                            ),
                          ),

                          // child: Text(
                          //   options[index],
                          //   style: TextStyle(
                          //     color: selectedOption == index
                          //         ? Color(0xFFFF8A00)
                          //         : Color(0xFF929292),
                          //   ),
                          // ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Thanh tìm kiếm
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tìm kiếm món ăn',
                            hintStyle: TextStyle(
                              color: Color(0xFF929292),
                              fontSize: 13,
                            )),
                        onChanged: (value) {
                          setState(() {
                            filteredItems = menuItems
                                .where((item) => item['item_name']
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Danh sách món ăn
              Expanded(
                child: ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return FoodItem(
                      id: filteredItems[index]['item_id'],
                      name: filteredItems[index]['item_name'],
                      status: filteredItems[index]['item_describe'] ?? '...',
                      price: filteredItems[index]['item_price_formatted'],
                      onAdd: () {
                        setState(() {
                          final item = filteredItems[index];
                          bool exists = false;

                          // Kiểm tra xem món ăn đã tồn tại chưa
                          for (var selected in selectedItems) {
                            if (selected['item_name'] == item['item_name']) {
                              selected['quantity'] += 1; // Tăng số lượng
                              exists = true;
                              break;
                            }
                          }

                          // Nếu món chưa tồn tại, thêm mới
                          if (!exists) {
                            selectedItems.add({
                              'item_name': item['item_name'],
                              'item_describe': item['item_describe'] ?? '',
                              'item_price': int.tryParse(
                                      item['item_price_formatted']
                                          ?.replaceAll('.', '')
                                          .replaceAll(' đ', '')) ??
                                  0,
                              'quantity': 1, // Số lượng ban đầu là 1
                            });
                          }
                        });

                        print('Đã thêm: ${filteredItems[index]['item_name']}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Overlay ListOrderFood
          if (_showOverlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    1, // Đặt chiều cao rõ ràng
                child: ListOrderFood(
                  selectedItems: selectedItems,
                  onClose: () {
                    setState(() {
                      _showOverlay = false;
                    });
                  },
                  onUpdateQuantity: (index, delta) {
                    setState(() {
                      selectedItems[index]['quantity'] += delta;
                      if (selectedItems[index]['quantity'] <= 0) {
                        selectedItems.removeAt(index);
                      }
                    });
                  },
                  onClearAll: () {
                    setState(() {
                      selectedItems
                          .clear(); // Xóa danh sách trên `OrderFoodScreen`
                    });
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.white,
        child: Row(
          children: [
            Container(
              width: 60,
              child: Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    color: Colors.orange,
                    onPressed: () {
                      setState(() {
                        _showOverlay = !_showOverlay; // Hiển thị/Ẩn overlay
                      });
                    },
                  ),
                  if (_calculateTotalItems() > 0)
                    Positioned(
                      right: 18,
                      top: -1,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_calculateTotalItems()}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _saveOrderAndSendToKitchen, // Gọi hàm lưu và gửi
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Lưu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Điều hướng đến màn hình mới
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PayPrintScreen()), // Thay `NewScreen` bằng tên màn hình bạn muốn chuyển đến
                  );
                },
                child: Container(
                  color: Colors.orange, // Màu nền cột 3
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_calculateTotal()} đ', // Hiển thị tổng tiền
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 5), // Khoảng cách giữa text và icon
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
