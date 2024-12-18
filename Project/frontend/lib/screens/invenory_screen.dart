import 'package:flutter/material.dart';
import 'package:app/models/item.dart';
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
      _unitController.text = item.unit.toString();
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
                _buildTextField(_unitController, 'Đơn vị', isNumber: true),
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
            labelText: 'Hạn sử dụng',
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

  void _showSettingsMenu() {
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
              title: Text('Chọn nhiều sản phẩm'),
              onTap: () {
                Navigator.pop(context);
                _showSelectMultipleItems();
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
        itemType: int.parse(_itemTypeController.text),
        quantity: int.parse(_quantityController.text),
        expItem: parsedDate,
        inventoryStatus: status,
        price: int.parse(_priceController.text),
        unit: _unitController.text,
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
      appBar: AppBar(
        title: Text(
          'Kho hàng',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.white, width: 1.0),
            ),
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: _showSettingsMenu,
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
                hintText: 'Tìm kiếm theo tên...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[300],
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // Kiểm tra trạng thái loading hoặc danh sách item
          _isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : displayedItems.isEmpty
                  ? Expanded(
                      child: Center(child: Text('Không có hàng hóa nào')))
                  : Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.0),
                        itemCount: displayedItems.length,
                        itemBuilder: (context, index) {
                          final item = displayedItems[index];
                          return GestureDetector(
                            onLongPress: () {
                              _showItemOptions(item);
                            },
                            child: Card(
                              margin: EdgeInsets.only(bottom: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side:
                                    BorderSide(color: Colors.white, width: 1.0),
                              ),
                              elevation: 4.0,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 16.0),
                                title: Text(
                                  item.itemName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Số lượng: ${item.quantity}'),
                                    Text('Giá tiền: ${item.price}'),
                                    Text('Đơn vị: ${item.unit}'),
                                    Text(
                                        'Hạn sử dụng: ${item.expItem.year}-${item.expItem.month.toString().padLeft(2, '0')}-${item.expItem.day.toString().padLeft(2, '0')}'),
                                    Text(
                                        'Trạng thái: ${item.inventoryStatus ? 'Còn hàng' : 'Hết hàng'}'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
