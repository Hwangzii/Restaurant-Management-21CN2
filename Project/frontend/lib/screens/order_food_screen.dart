import 'package:app/widgets/food_items.dart';
import 'package:flutter/material.dart';

class OrderFoodScreen extends StatefulWidget {
  const OrderFoodScreen({super.key});

  @override
  State<OrderFoodScreen> createState() => _OrderFoodScreenState();
}

class _OrderFoodScreenState extends State<OrderFoodScreen> {
  TextEditingController searchController = TextEditingController();

  // Danh sách món ăn
  final List<String> foodNames = List.generate(100, (index) => 'Món ăn ${index + 1}');
  List<String> filteredItems = [];
  int selectedOption = 0; // Tùy chọn mặc định là "Tất cả"

  @override
  void initState() {
    super.initState();
    _filterItemsByOption(selectedOption);
  }

  // Hàm lọc danh sách món ăn dựa trên tùy chọn
  void _filterItemsByOption(int option) {
    setState(() {
      if (option == 0) {
        // Hiển thị tất cả món ăn
        filteredItems = foodNames;
      } else {
        int startIndex = (option - 1) * 10;
        int endIndex = startIndex + 10;
        filteredItems = foodNames.sublist(startIndex, endIndex.clamp(0, foodNames.length));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Bàn 100',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F3F4),
      body: Column(
        children: [
          // Thanh tùy chọn ngang
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
                        filteredItems = foodNames
                            .where((name) => name.toLowerCase().contains(value.toLowerCase()))
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
                  name: filteredItems[index],
                  status: 'hết hàng',
                  price: '\$10.99',
                  onAdd: () {
                    print('Đã gọi món: ${filteredItems[index]}');
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