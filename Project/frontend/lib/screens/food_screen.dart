import 'package:flutter/material.dart';
import 'package:app/widgets/food_items.dart';
import 'package:app/controllers/food_controller.dart';
import 'package:app/services/api_service.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  List<Map<String, dynamic>> menuItems = [];  // Danh sách món ăn
  List<Map<String, dynamic>> filteredItems = []; // Món ăn sau khi lọc (nếu cần)

  final FoodController foodController = FoodController(ApiService());


  // Controllers cho form thêm món ăn mới
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  TextEditingController itemDescribeController = TextEditingController();
  TextEditingController itemTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMenuItems();  // Gọi hàm tải món ăn khi màn hình được tạo
  }

  Future<void> _loadMenuItems() async {
    try {
      List<Map<String, dynamic>> fetchedItems =
          await FoodController.fetchMenuItems();  // Lấy món ăn từ controller
      setState(() {
        menuItems = fetchedItems;  // Lưu món ăn vào danh sách
        filteredItems = menuItems; // Gán món ăn đã lấy vào danh sách hiển thị
      });
    } catch (e) {
      print('Error loading menu items: $e');  // In lỗi nếu có
    }
  }

   // Hiển thị form thêm món ăn
  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm món ăn mới'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: const InputDecoration(labelText: 'Tên món ăn'),
                ),
                TextField(
                  controller: itemPriceController,
                  decoration: const InputDecoration(labelText: 'Giá món ăn'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: itemDescribeController,
                  decoration: const InputDecoration(labelText: 'Mô tả món ăn'),
                ),
                DropdownButtonFormField<int>(
                value: int.tryParse(itemTypeController.text) ?? 1, // Giá trị mặc định là 1
                decoration: const InputDecoration(labelText: 'Loại món ăn'),
                items: [
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text('Món chính'),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child: Text('Đồ uống'),
                  ),
                  DropdownMenuItem<int>(
                    value: 3,
                    child: Text('Buffet đỏ'),
                  ),
                  DropdownMenuItem<int>(
                    value: 4,
                    child: Text('Buffet đenen'),
                  ),
                ],
                onChanged: (newValue) {
                  setState(() {
                    itemTypeController.text = newValue.toString(); // Cập nhật giá trị của controller
                  });
                },
              ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final itemName = itemNameController.text.trim();
                final itemPrice = double.tryParse(itemPriceController.text);
                final itemDescribe = itemDescribeController.text.trim();
                final itemType = int.tryParse(itemTypeController.text)??1 ;
                final itemStatus = true;
                final restaurant = 2;
                if (itemName.isEmpty || itemPrice == null || itemPrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập thông tin hợp lệ!'),
                    ),
                  );
                  return;
                }

                try {
                  final success = await foodController.addFood(

                    itemName,
                    itemPrice,
                    itemDescribe,
                    itemType, 
                    itemStatus, // true
                    restaurant, // mac dinh la 2
                    
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm món ăn thành công!')),
                    );
                    Navigator.of(context).pop();
                    _loadMenuItems(); // Tải lại danh sách món ăn
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm món ăn thất bại!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              },
              child: const Text('Thêm'),
            ),
          ],
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
      title: const Text(
        'Danh sách món ăn',
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>( 
          onSelected: (value) {
            if (value == 'add_new') {
              _showAddFoodDialog(); // Thêm món ăn mới
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'add_new',
                child: Text('Thêm món ăn mới'),
              ),
              PopupMenuItem<String>(
                value: 'select_multiple',
                child: Text('Chọn nhiều món'),
              ),
            ];
          },
        ),
      ],
    ),
    backgroundColor: const Color(0xFFF2F3F4),
    body: menuItems.isEmpty
        ? const Center(child: CircularProgressIndicator())  // Hiển thị loading khi chưa có món ăn
        : ListView.builder(
            itemCount: filteredItems.length,  // Đếm số món ăn để hiển thị
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(filteredItems[index]['item_name']),  // Sử dụng key để xác định mỗi item
                direction: DismissDirection.endToStart,  // Vuốt từ phải sang trái
                onDismissed: (direction) async {
                  try {
                    // Gọi phương thức deleteItem để xóa món ăn trên server
                    await foodController.deleteItem(filteredItems[index]['item_id']); 

                    // Sau khi xóa, cập nhật danh sách món ăn
                    setState(() {
                      filteredItems.removeAt(index);  // Xóa item khỏi danh sách hiển thị
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xóa món ăn!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi xóa món ăn: $e')),
                    );
                  }
                },
                background: Container(
                  color: Colors.red,  // Màu nền khi vuốt qua
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                child: FoodItem(
                  name: filteredItems[index]['item_name'],
                  status: filteredItems[index]['item_describe'] ?? '...',
                  price: filteredItems[index]['item_price_formatted'],
                  id: filteredItems[index]['item_id'],
                  onAdd: () {
                    print('Đã thêm: ${filteredItems[index]['item_name']}');
                  },
                ),
              );
            },
          ),
  );
}

}
