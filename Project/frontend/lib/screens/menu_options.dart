import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuOptionsScreen(),
    );
  }
}

class MenuOptionsScreen extends StatelessWidget {
  // Danh sách các danh mục
  final List<Map<String, dynamic>> categories = [
  {'icon': Icons.restaurant_menu, 'title': 'Gọi món'}, // Icon thể hiện thực đơn gọi món
  {'icon': Icons.fireplace, 'title': 'Đồ Nướng'}, // Icon thể hiện nướng (lửa)
  {'icon': Icons.set_meal, 'title': 'Set'}, // Icon thể hiện các combo/sets
  {'icon': Icons.dining, 'title': 'Buffet Đỏ'}, // Icon thể hiện ăn uống (bữa ăn sang trọng)
  {'icon': Icons.rice_bowl, 'title': 'Buffet Đen'}, // Icon thể hiện món châu Á (bát cơm)
  {'icon': Icons.child_friendly, 'title': 'Buffet Trẻ em'}, // Icon thể hiện trẻ em (phù hợp buffet trẻ)
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Mục Tùy Chọn'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Số cột trong Grid
            crossAxisSpacing: 16, // Khoảng cách giữa các cột
            mainAxisSpacing: 16, // Khoảng cách giữa các hàng
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                // Chuyển đến trang danh sách món ăn
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodListScreen(category['title']),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'], size: 40, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      category['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FoodListScreen extends StatelessWidget {
  final String categoryTitle;

  FoodListScreen(this.categoryTitle);

  // Danh sách món ăn theo từng danh mục
  final Map<String, List<String>> foodItems = {
    'Gọi món': [
      'Sườn non thượng hạng (200g) – 600.000 VNĐ',
      'Sườn non thượng hạng tẩm ướp (200g) – 600.000 VNĐ',
      'Thăn hoàng đế (200g) – 500.000 VNĐ',
      'Dẻ sườn đế vương tẩm ướp (200g) – 400.000 VNĐ',
      'Lõi vai bò (200g) – 400.000 VNĐ',
      'Lòng non bò nướng (200g) – 220.000 VNĐ',
      'Sò điệp nướng sốt cay (4 con) – 100.000 VNĐ',
      'Mực nướng (200g) – 120.000 VNĐ',
      'Tôm nướng (4 con) – 100.000 VNĐ',
      'Phomai nướng – 150.000 VNĐ',
    ],
    'Đồ Nướng': [
      'Sườn non thượng hạng – 600.000 VNĐ',
      'Thăn hoàng đế – 500.000 VNĐ',
      'Dẻ sườn đế vương – 400.000 VNĐ',
      'Lõi vai bò – 400.000 VNĐ',
      'Mực nướng – 120.000 VNĐ',
      'Tôm nướng – 100.000 VNĐ',
    ],
    'Set': [
      'Set to (1kg) – 2.200.000 VNĐ',
      'Set vừa (800g) – 1.810.000 VNĐ',
      'Set nhỏ (600g) – 1.430.000 VNĐ',
    ],
    'Buffet Đỏ': [
      'Buffet đỏ (Thứ 2-6) – 500.000 VNĐ',
      'Buffet đỏ (Thứ 7,CN) – 550.000 VNĐ',
      'Thăn hoàng đế (100g)',
      'Lõi vai bò (100g)',
      'Gà rán sốt cay',
      'Canh kim chi',
    ],
    'Buffet Đen': [
      'Buffet đen (Thứ 2-6) – 550.000 VNĐ',
      'Buffet đen (Thứ 7,CN) – 600.000 VNĐ',
      'Sò điệp nướng sốt cay (2 con)',
      'Tôm nướng',
      'Canh rong biển thịt bò',
      'Topokki nướng',
    ],
    'Buffet Trẻ em': [
      'Buffet trẻ em – 200.000 VNĐ',
      'Tôm nướng',
      'Phomai nướng',
      'Ngô phô mai',
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách món ăn dựa trên danh mục
    final items = foodItems[categoryTitle] ?? ['Chưa có món ăn'];

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                items[index],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              leading: Icon(Icons.food_bank, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}
