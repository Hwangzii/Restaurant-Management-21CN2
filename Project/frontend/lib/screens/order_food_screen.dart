import 'package:app/controllers/oder_food_controller.dart';
import 'package:app/screens/pay_print_screen.dart';
import 'package:app/widgets/list_order_food.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/food_items.dart';


class OrderFoodScreen extends StatefulWidget {
  final String tableName;
  final String selectedType;
  

  const OrderFoodScreen(
      {super.key, required this.tableName, required this.selectedType});

  @override
  State<OrderFoodScreen> createState() => _OrderFoodScreenState();
}

class _OrderFoodScreenState extends State<OrderFoodScreen> {
  TextEditingController searchController = TextEditingController();
  bool _showOverlay = false; // Biến điều khiển hiển thị overlay

  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> selectedItems = []; // Danh sách món đã chọn
  int selectedOption = 0;


  final List<String> options = [
    'Tất cả',
    'Món chính',
    'Đồ uống',
    'Buffee đỏ',
    'Buffee đen',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      List<Map<String, dynamic>> fetchedItems =
          await OrderFoodController.fetchMenuItems();
      setState(() {
        menuItems = fetchedItems;
        // filteredItems = menuItems;
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
        // Buffet đỏ thường và trẻ em
        filteredItems = menuItems
            .where((item) => item['item_type'] == 3 || item['item_type'] == 5)
            .toList();
      } else if (selectedType == 'Buffet đen') {
        // Buffet đen thường và trẻ em
        filteredItems = menuItems
            .where((item) => item['item_type'] == 4 || item['item_type'] == 6)
            .toList();
      } else {
        // Gọi món: Hiển thị tất cả
        filteredItems = menuItems;
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

  int _TotalQuantityDish(){
    return selectedItems.fold(0, (sum, item) {
      try {
        int quantity = item['quantity'] ?? 0; // Chỉ lấy tổng số lượng
        return sum + quantity;
      } catch (e) {
        print('Lỗi tính tổng số lượng: $e');
        return sum;
      }
    });
  }

  void _filterItemsByOption(int option) {
    setState(() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('${widget.tableName}',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
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
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: selectedOption == index ? Color(0xFFF2F2F2) : Colors.white,
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
                          )
                        ),
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
                height: MediaQuery.of(context).size.height * 1, // Đặt chiều cao rõ ràng
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

      // Thanh nút ấn xem danh sách món đã gọi, lưu, chuyển đến form thanh toán
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.white,
        child: Row(
          children: [
            Container(
              width: 50,
              child: Stack(
                children: [
                  IconButton(
                    icon: Image.asset('assets/shopping-cart.png',height: 24, width: 24),
                    onPressed: () {
                      setState(() {
                        _showOverlay = !_showOverlay; // Hiển thị/Ẩn overlay
                      });
                    },
                  ),
                  Positioned(
                    right: 2, // Đặt số về phía góc phải
                    top: 1,   // Đặt số về phía góc trên
                    child: _TotalQuantityDish() > 0
                        ? Container(
                            height: 18,
                            width: 18,
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red, // Màu nền đỏ
                              shape: BoxShape.circle, // Nền hình tròn
                            ),
                            child: Text(
                              '${_TotalQuantityDish()}', // Hiển thị số
                              style: TextStyle(
                                color: Colors.white, // Màu chữ trắng
                                fontSize: 10, // Kích thước chữ
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center, // Căn giữa chữ trong container
                            ),
                          )
                        : SizedBox.shrink(), // Trả về widget trống khi số lượng = 0
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Lưu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF929292),
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
                    MaterialPageRoute(builder: (context) => PayPrintScreen()), // Thay `NewScreen` bằng tên màn hình bạn muốn chuyển đến
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
                      Image.asset(
                        'assets/angle-small-right.png',
                        width: 15,
                        height: 15,
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
