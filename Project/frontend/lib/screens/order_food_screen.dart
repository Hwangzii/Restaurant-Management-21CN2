import 'package:app/controllers/oder_food_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/food_items.dart';

class OrderFoodScreen extends StatefulWidget {
  final String tableName;

  const OrderFoodScreen({super.key, required this.tableName});

  @override
  State<OrderFoodScreen> createState() => _OrderFoodScreenState();
}

class _OrderFoodScreenState extends State<OrderFoodScreen> {
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  int selectedOption = 0;

  // Danh sách tùy chọn
  final List<String> options = [
    'Tất cả',
    'Món chính',
    'Đồ uống',
    'Tráng miệng',
    'Buffee',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  // Tải danh sách món ăn từ controller
  Future<void> _loadMenuItems() async {
    try {
      List<Map<String, dynamic>> fetchedItems =
          await OrderFoodController.fetchMenuItems();
      setState(() {
        menuItems = fetchedItems;
        filteredItems = menuItems;
      });
    } catch (e) {
      print('Error loading menu items: $e');
    }
  }

  // Lọc món ăn theo tùy chọn đã chọn
  void _filterItemsByOption(int option) {
    setState(() {
      if (option == 0) {
        // Tất cả (hiển thị món ăn có item_type từ 1 đến 4)
        filteredItems = menuItems.where((item) {
          return item['item_type'] >= 1 && item['item_type'] <= 4;
        }).toList();
      } else {
        // Lọc theo item_type
        int selectedType = option; // Tùy chọn từ 1 đến 4
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
        elevation: 0,
        title: Text('${widget.tableName}',
            style: TextStyle(color: Colors.black, fontSize: 20)),
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
              itemCount: options.length,
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
                      options[index],
                      style: TextStyle(
                        color: selectedOption == index
                            ? Colors.orange
                            : Colors.black,
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
                  // Kiểm tra item_describe, nếu không có thì hiển thị "Mô tả không có sẵn"
                  status: filteredItems[index]['item_describe'] != null
                      ? filteredItems[index]['item_describe']
                      : '...',
                  price: filteredItems[index]['item_price_formatted'],
                  onAdd: () {
                    print('Đã gọi món: ${filteredItems[index]['item_name']}');
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
