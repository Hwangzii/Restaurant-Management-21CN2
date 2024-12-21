import 'package:flutter/material.dart';

class FoodItem extends StatelessWidget {
  final String name;
  final String status;
  final String price;
  final int id; // Thêm id để xác định món ăn
  final VoidCallback onAdd;

  const FoodItem({
    Key? key,
    required this.onAdd,
    required this.name,
    required this.status,
    required this.price,
    required this.id, // Nhận id món ăn
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tạo tên hình ảnh dựa trên id
    String imagePath = _getImagePath(id);

    return GestureDetector(
      onTap: onAdd,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                // Hình ảnh món ăn
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: AssetImage(imagePath), // Sử dụng đường dẫn hình ảnh động
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Nội dung thông tin món ăn
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên món ăn
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      // Trạng thái món ăn
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: Color(0xFF929292),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      // Giá món ăn
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Đường kẻ mờ
          const Divider(
            height: 0.5,
            color: Color(0xFFF2F3F4),
            indent: 16.0, // Căn lề trái
            endIndent: 16.0, // Căn lề phải
          ),
        ],
      ),
    );
  }

  // Hàm trả về đường dẫn hình ảnh dựa trên id
  String _getImagePath(int id) {
    // Kiểm tra nếu id hợp lệ và có ảnh tương ứng
    if (id >= 1 && id <= 115) {
      return 'assets/food_photo/$id.png'; // Đường dẫn hình ảnh theo id
    } else {
      return 'assets/image.png'; // Hình ảnh mặc định nếu không tìm thấy
    }
  }
}
