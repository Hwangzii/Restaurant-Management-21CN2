import 'package:flutter/material.dart';

class FoodItem extends StatefulWidget {
  final String name;
  final String status;
  final String price;
  final VoidCallback onAdd;

  const FoodItem({
    Key? key,
    required this.onAdd,
    required this.name,
    required this.status,
    required this.price,
  }) : super(key: key);

  @override
  _FoodItemState createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem> {
  int quantity = 0;

  void _increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decreaseQuantity() {
    setState(() {
      if (quantity > 0) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // Hình ảnh món ăn
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: const DecorationImage(
                    image: AssetImage('assets/diet.png'), // Hình ảnh món ăn
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
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    // Trạng thái món ăn
                    Text(
                      widget.status,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    // Giá món ăn
                    Text(
                      widget.price,
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
          // Điều chỉnh số lượng nằm ở góc phải dưới cùng
          Positioned(
            right: 0.0, // Khoảng cách từ cạnh phải
            bottom: 0.0, // Khoảng cách từ cạnh dưới
            child: Row(
              children: [
                // Dấu trừ và số chỉ hiện khi quantity > 0
                if (quantity > 0) ...[
                  GestureDetector(
                    onTap: _decreaseQuantity,
                    child: Image.asset(
                      'assets/square-minus.png', // Biểu tượng trừ
                      width: 25.0,
                      height: 25.0,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  // Số lượng
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                ],
                // Dấu cộng
                GestureDetector(
                  onTap: _increaseQuantity,
                  child: Image.asset(
                    'assets/square-plus.png', // Biểu tượng cộng
                    width: 25.0,
                    height: 25.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
