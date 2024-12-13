import 'package:app/controllers/oder_food_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/food_items.dart';


class OrderFoodScreen extends StatefulWidget {
  final String tableName; // Thêm tableName làm tham số

  const OrderFoodScreen({super.key, required this.tableName}); // Cập nhật constructor


  @override
  State<OrderFoodScreen> createState() => _OrderFoodScreenState();
}

class _OrderFoodScreenState extends State<OrderFoodScreen> {
  TextEditingController searchController = TextEditingController();

  // Danh sách món ăn và các món ăn đã lọc
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  int selectedOption = 0;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  // Hàm tải danh sách món ăn từ API
  Future<void> _loadMenuItems() async {
    try {
      List<Map<String, dynamic>> fetchedItems = await OrderFoodController.fetchMenuItems();
      setState(() {
        menuItems = fetchedItems;
        filteredItems = menuItems;
      });
    } catch (e) {
      print('Error loading menu items: $e');
    }
  }

  // Hàm lọc món ăn theo lựa chọn
  void _filterItemsByOption(int option) {
    setState(() {
      if (option == 0) {
        filteredItems = menuItems;
      } else {
        int startIndex = (option - 1) * 10;
        int endIndex = startIndex + 10;
        filteredItems = menuItems.sublist(startIndex, endIndex.clamp(0, menuItems.length));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('${widget.tableName}', style: TextStyle(color: Colors.black, fontSize: 20)), // Sử dụng tableName
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F3F4),
      body: Column(
        children: [
          // Thanh tùy chọn
          Container(
            color: Colors.white,
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 11,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedOption = index;
                        _filterItemsByOption(index);
                      });
                    },
                    child: Text(
                      index == 0 ? 'Tất cả' : 'Tùy chọn $index',
                      style: TextStyle(
                        color: selectedOption == index ? Colors.orange : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Thanh tìm kiếm
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  name: filteredItems[index]['item_name'],
                  status: filteredItems[index]['item_status'] ? 'Còn hàng' : 'Hết hàng',
                  price: '\$${filteredItems[index]['item_price']}',
                  onAdd: () {
                    print('Đã gọi món: ${filteredItems[index]['item_name']}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
