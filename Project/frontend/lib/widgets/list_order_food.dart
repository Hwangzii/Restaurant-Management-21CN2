import 'package:flutter/material.dart';

class ListOrderFood extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final VoidCallback onClose; // Để ẩn overlay
  final Function(int, int) onUpdateQuantity; // Cập nhật số lượng từ bên ngoài
  final VoidCallback onClearAll;

  const ListOrderFood({
    Key? key,
    required this.selectedItems,
    required this.onClose,
    required this.onUpdateQuantity,
    required this.onClearAll,
  }) : super(key: key);

  @override
  _ListOrderFoodState createState() => _ListOrderFoodState();
}

class _ListOrderFoodState extends State<ListOrderFood> {
  void _updateQuantity(int index, int delta) {
    setState(() {
      widget.onUpdateQuantity(index, delta); // Gọi callback để cập nhật dữ liệu
    });
  }

  void _clearAllItems() {
    setState(() {
      widget.selectedItems.clear(); // Xóa toàn bộ danh sách
      widget.onClearAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Nền đen mờ
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        // Nội dung chính
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _clearAllItems,
                        child: Text(
                          'Xóa tất cả',
                          style: TextStyle(color: Colors.orange, fontSize: 16),
                        ),
                      ),
                      Text('Danh sách món', style: TextStyle(fontSize: 18)),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade300),

                // Danh sách món ăn
                Expanded(
                  child: widget.selectedItems.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có món nào được chọn!',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.builder(
                          itemCount: widget.selectedItems.length,
                          itemBuilder: (context, index) {
                            final item = widget.selectedItems[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tên món ăn
                                  Text(
                                    item['item_name'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  // Ghi chú
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Thêm ghi chú...',
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 4.0),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        item['note'] = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 4),
                                  // Hàng ngang: Giá tiền + Nút cộng/trừ
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Giá tiền
                                      Text(
                                        '${item['item_price']} đ',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.orange),
                                      ),

                                      // Nút cộng/trừ
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.remove,
                                                  size: 16,
                                                  color: Colors.white),
                                              onPressed: () =>
                                                  _updateQuantity(index, -1),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              '${item['quantity']}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.add,
                                                  size: 16,
                                                  color: Colors.white),
                                              onPressed: () =>
                                                  _updateQuantity(index, 1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Divider(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
