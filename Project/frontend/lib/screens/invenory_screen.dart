import 'package:flutter/material.dart';
import 'package:app/models/item.dart';
import 'package:intl/intl.dart';
import '../controllers/inventory_controller.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryController _controller = InventoryController();

  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _expItemController = TextEditingController();
  final _paymentmethodController = TextEditingController();
  final _inventoryStatusController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _searchController = TextEditingController();
  Item? _selectedItem;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await _controller.loadItems();
    setState(() {
      _isLoading = false;
    });
  }

  void _showForm(Item? item) {
    if (item != null) {
      _itemNameController.text = item.itemName;
      _itemTypeController.text = item.itemType.toString();
      _quantityController.text = item.quantity.toString();
      _priceController.text = item.price.toString();
      _unitController.text = item.unit;
      _paymentmethodController.text = item.paymentmethod.toString();
      _expItemController.text =
          "${item.expItem.year}-${item.expItem.month.toString().padLeft(2, '0')}-${item.expItem.day.toString().padLeft(2, '0')}";
      _inventoryStatusController.text =
          item.inventoryStatus ? 'Còn hàng' : 'Hết hàng';
      _selectedItem = item;
    } else {
      _itemNameController.clear();
      _itemTypeController.text = '1';
      _quantityController.clear();
      _expItemController.clear();
      _priceController.clear();
      _paymentmethodController.clear();
      _itemTypeController.clear();
      _inventoryStatusController.text = 'Còn hàng';
      _selectedItem = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item == null ? 'Thêm hàng hóa' : 'Sửa thông tin hàng hóa',
          style: TextStyle(color: Colors.black),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_itemNameController, 'Tên hàng'),
                SizedBox(height: 12), // Khoảng cách
                DropdownButtonFormField<int>(
                  value: int.tryParse(_itemTypeController.text) ?? 1,
                  items: [
                    DropdownMenuItem(value: 1, child: Text('Thực phẩm')),
                    DropdownMenuItem(value: 2, child: Text('Vật dụng')),
                  ],
                  onChanged: (value) {
                    _itemTypeController.text = value.toString();
                  },
                  decoration: InputDecoration(
                    labelText: 'Loại hàng',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12), // Khoảng cách
                _buildTextField(_quantityController, 'Số lượng',
                    isNumber: true),
                SizedBox(height: 12), // Khoảng cách
                _buildTextField(_priceController, 'Giá tiền', isNumber: true),
                SizedBox(height: 12), // Khoảng cách
                _buildTextField(_unitController, 'Đơn vị'),
                SizedBox(height: 12), // Khoảng cách
                DropdownButtonFormField<String>(
                  value: _paymentmethodController.text.isNotEmpty
                      ? _paymentmethodController.text
                      : 'Tiền mặt', // Giá trị mặc định
                  items: [
                    DropdownMenuItem(
                        value: 'Tiền mặt', child: Text('Tiền mặt')),
                    DropdownMenuItem(
                        value: 'Chuyển khoản', child: Text('Chuyển khoản')),
                  ],
                  onChanged: (value) {
                    _paymentmethodController.text = value!;
                  },
                  decoration: InputDecoration(
                    labelText: 'Phương thức thanh toán',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12), // Khoảng cách
                _buildDateField(),
                SizedBox(height: 12), // Khoảng cách
                DropdownButtonFormField<String>(
                  value: _inventoryStatusController.text,
                  items: [
                    DropdownMenuItem(
                        value: 'Còn hàng', child: Text('Còn hàng')),
                    DropdownMenuItem(
                        value: 'Hết hàng', child: Text('Hết hàng')),
                  ],
                  onChanged: (value) {
                    _inventoryStatusController.text = value!;
                  },
                  decoration: InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Đóng', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: _saveItem,
            child: Text('Lưu', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
        border: OutlineInputBorder(),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          setState(() {
            _expItemController.text =
                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          });
        }
      },
      child: IgnorePointer(
        child: TextFormField(
          controller: _expItemController,
          decoration: InputDecoration(
            labelText: 'Ngày nhập',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2.0),
            ),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Vui lòng chọn ngày';
            return null;
          },
        ),
      ),
    );
  }

  void _showItemOptions(Item item) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Sửa sản phẩm'),
              onTap: () {
                Navigator.pop(context);
                _showForm(item);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Xóa sản phẩm'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(item.itemId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSettingsMenu(Item item) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: [
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Thêm sản phẩm'),
              onTap: () {
                Navigator.pop(context);
                _showForm(null); // Thêm sản phẩm mới
              },
            ),
            ListTile(
              leading: Icon(Icons.check_box),
              title: Text('Xóa sản phẩm'),
              onTap: () {
                Navigator.pop(context);
                _showForm(item);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSelectMultipleItems() {
    // Hàm xử lý chọn nhiều sản phẩm sẽ ở đây
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final dateStr = _expItemController.text;
      final parsedDate = DateTime.tryParse(dateStr);
      if (parsedDate == null) return;

      final bool status = _inventoryStatusController.text == 'Còn hàng';

      final item = Item(
        itemId: _selectedItem?.itemId ?? 0,
        itemName: _itemNameController.text,
        itemType: int.tryParse(_itemTypeController.text) ?? 1,
        quantity: int.parse(_quantityController.text),
        expItem: parsedDate,
        inventoryStatus: status,
        price: int.parse(_priceController.text),
        unit: _unitController.text,
        paymentmethod: _paymentmethodController.text.isNotEmpty
            ? _paymentmethodController.text
            : 'Tiền mặt', // Giá trị mặc định nếu paymentmethod rỗng
        restaurant: 2,
      );

      setState(() {
        _isLoading = true;
      });

      if (_selectedItem == null) {
        await _controller.createItem(item);
      } else {
        await _controller.updateItem(item);
      }

      Navigator.of(context).pop();
      await _loadData();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa', style: TextStyle(color: Colors.black)),
        content: Text('Bạn có chắc chắn muốn xóa mặt hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Hủy', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteItem(id);
            },
            child: Text('Xóa', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(int id) async {
    setState(() => _isLoading = true);
    await _controller.deleteItem(id);
    await _loadData();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _controller.setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedItems = _controller.displayedItems;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'Kho hàng',
          style: TextStyle(fontSize: 20, color: Color(0xFFEF4D2D)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.white, width: 1.0),
            ),
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _showForm(null);
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm căn giữa
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm",
                hintStyle: TextStyle(color: Color(0xFF808B96)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black, // Chỉnh màu icon search
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15), // Bo góc cho TextField
                  borderSide: BorderSide.none, // Không có viền
                ), // Bỏ viền
                filled: true,
                fillColor: Color(0xFFF4F3F8),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: _onSearchChanged,
              style: TextStyle(color: Colors.black),
            ),
          ),
          // Kiểm tra trạng thái loading hoặc danh sách item
          _isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : displayedItems.isEmpty
                  ? Expanded(
                      child: Center(child: Text('Không có hàng hóa nào')))
                  : Expanded(
                      child: ListView.separated(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: displayedItems.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300], // Màu của đường kẻ
                        thickness: 1, // Độ dày của đường kẻ
                        indent: 16, // Khoảng cách từ lề trái
                        endIndent: 16, // Khoảng cách từ lề phải
                      ),
                      itemBuilder: (context, index) {
                        final item = displayedItems[index];

                        return GestureDetector(
                          onLongPress: () {
                            _showItemOptions(
                                item); // Hiển thị menu tùy chọn khi nhấn giữ
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cột trái
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Số lượng:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFABB2B9),
                                        ),
                                      ),
                                      Text(
                                        'Giá tiền:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFABB2B9),
                                        ),
                                      ),
                                      Text(
                                        'Đơn vị:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFABB2B9),
                                        ),
                                      ),
                                      Text(
                                        'Ngày nhập:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFABB2B9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Cột phải
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Icon(
                                        item.inventoryStatus
                                            ? Icons
                                                .check_circle // Icon when inventoryStatus is true
                                            : Icons
                                                .cancel, // Icon when inventoryStatus is false
                                        color: item.inventoryStatus
                                            ? Colors
                                                .green // Green color for true
                                            : Colors
                                                .grey, // Red color for false
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        '${item.quantity}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFABB2B9),
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat.currency(locale: 'vi_VN').format(item.price)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFABB2B9),
                                        ),
                                      ),
                                      Text(
                                        '${item.unit}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFABB2B9),
                                        ),
                                      ),
                                      Text(
                                        '${item.expItem.year}-${item.expItem.month.toString().padLeft(2, '0')}-${item.expItem.day.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFABB2B9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
        ],
      ),
    );
  }
}
