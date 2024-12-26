import 'package:app/controllers/oder_food_controller.dart';
import 'package:app/controllers/tables_controller.dart';
import 'package:app/screens/pay_print_screen.dart';
import 'package:app/widgets/list_order_food.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/food_items.dart';

class OrderFoodScreen extends StatefulWidget {
  final String tableName;
  final String selectedType;
  final int guestCount;
  final int buffetTotal;
  final VoidCallback onUpdate; // Hàm callback để gọi

  const OrderFoodScreen({
    Key? key,
    required this.tableName,
    required this.selectedType,
    required this.guestCount,
    this.buffetTotal = 0,
    required this.onUpdate,
  }) : super(key: key);

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
  bool isButtonDisabled = false; // Biến kiểm soát trạng thái nút
  late List<String> options;

  @override
  void initState() {
    super.initState();

    // Thiết lập options dựa trên loại món
    if (widget.selectedType.contains('Buffet')) {
      options = ['Thường', 'Cho trẻ em', 'Món chính', 'Đồ uống'];
    } else {
      options = ['Tất cả', 'Món chính', 'Đồ uống'];
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
        filteredItems =
            menuItems.where((item) => item['item_type'] == 3).toList();
      } else if (selectedType == 'Buffet đen') {
        filteredItems =
            menuItems.where((item) => item['item_type'] == 4).toList();
      } else {
        filteredItems = menuItems;
      }
    });
  }

  Future<void> _saveOrderAndSendToKitchen() async {
    if (isButtonDisabled) return;

    if (selectedItems.isEmpty && widget.buffetTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có món nào để gửi!')),
      );
      return;
    }

    setState(() {
      isButtonDisabled = true; // Vô hiệu hóa nút
    });

    try {
      // Kiểm tra nếu bàn đã có Buffet
      bool hasBuffet = await OrderFoodController.hasBuffet(widget.tableName);

      Map<String, dynamic>? buffet = (!hasBuffet && widget.buffetTotal > 0)
          ? {
              'item_name': widget.selectedType, // Buffet đỏ / Buffet đen
              'quantity': widget.guestCount,
              'item_price': widget.buffetTotal,
              'status': 'Pending',
            }
          : null; // Không gửi Buffet nếu đã tồn tại

      // Gửi các món ăn khác
      List<Map<String, dynamic>> itemsToSend = selectedItems.map((item) {
        return {
          'item_name': item['item_name'],
          'quantity': item['quantity'],
          'item_price': item['item_price'],
          'type': widget.selectedType,
          'describe': item['note'],
          'status': 'Pending',
        };
      }).toList();

      // Gửi toàn bộ món ăn qua controller
      await OrderFoodController.sendOrderItems(
        tableName: widget.tableName,
        buffet: buffet, // Chỉ gửi Buffet nếu không trùng lặp
        items: itemsToSend,
      );
      await TablesController.checkAndUpdateTableStatus(widget.tableName);
      // Gọi hàm reload từ màn hình cha
      // ignore: unnecessary_null_comparison
      if (widget.onUpdate != null) {
        widget.onUpdate(); // Gọi callback
      }
      // Sau khi gửi, xóa danh sách món đã chọn
      setState(() {
        selectedItems.clear(); // Xóa danh sách các món đã chọn
      });

      // Hiển thị thông báo kết quả
      if (hasBuffet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Các món đã được gửi, Buffet không được gửi vì đã tồn tại!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đơn hàng đã được gửi tới bếp!'),
          ),
        );
      }
    } catch (e) {
      print('Lỗi khi gửi đơn hàng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi đơn hàng.')),
      );
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isButtonDisabled = false; // Kích hoạt lại nút
        });
      });
    }
  }

  Future<void> _upgradeBuffet(String tableName) async {
    try {
      await OrderFoodController.upgradeBuffet(tableName);
      // ignore: unnecessary_null_comparison
      if (widget.onUpdate != null) {
        widget.onUpdate(); // Gọi callback
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nâng cấp Buffet thành công!')),
      );

      // Reload giao diện
      setState(() {});
    } catch (e) {
      print('Error in _upgradeBuffet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể nâng cấp Buffet.')),
      );
    }
  }

  Future<void> _transferTable(String oldTableName) async {
    TextEditingController tableNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chuyển bàn'),
          content: TextField(
            controller: tableNameController,
            decoration: InputDecoration(hintText: 'Nhập tên bàn mới'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String newTableName = tableNameController.text.trim();
                if (newTableName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tên bàn không được để trống')),
                  );
                  return;
                }

                // Kiểm tra trạng thái bàn mới
                bool isAvailable =
                    !(await OrderFoodController.checkTableStatus(newTableName));
                if (!isAvailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bàn này không khả dụng')),
                  );
                  return;
                }

                // Thực hiện chuyển bàn
                try {
                  await OrderFoodController.transferOrders(
                    oldTableName: oldTableName,
                    newTableName: newTableName,
                  );
                  // ignore: unnecessary_null_comparison
                  if (widget.onUpdate != null) {
                    widget.onUpdate(); // Gọi callback
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chuyển bàn thành công!')),
                  );

                  // Quay lại màn table
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Đóng màn Order
                } catch (e) {
                  print('Error in transferTable: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi chuyển bàn.')),
                  );
                }
              },
              child: Text('Xác nhận'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
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

        // ignore: unnecessary_type_check
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
            icon: Icon(Icons.menu),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100.0, 100.0, 0.0, 0.0),
                items: [
                  PopupMenuItem<String>(
                    value: 'nang_cap',
                    child: Text('Nâng cấp'),
                  ),
                  PopupMenuItem<String>(
                    value: 'chuyen_ban',
                    child: Text('Chuyển bàn'),
                  ),
                ],
                elevation: 8.0,
              ).then((value) {
                if (value == 'nang_cap') {
                  _upgradeBuffet(widget.tableName);
                } else if (value == 'chuyen_ban') {
                  print('Chuyển bàn');
                  _transferTable(widget.tableName);
                }
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
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
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: _saveOrderAndSendToKitchen, // Gọi hàm lưu và gửi
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Màu nền
                  foregroundColor: Colors.black, // Màu chữ
                  elevation: 0, // Bỏ đổ bóng
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Bo góc
                  ),
                ),
                child: Text(
                  'Lưu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black, // Màu chữ
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
                        builder: (context) => PayPrintScreen(
                              tableName: widget.tableName,
                              buffetTotal: widget.buffetTotal,
                            )), // Thay `NewScreen` bằng tên màn hình bạn muốn chuyển đến
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
