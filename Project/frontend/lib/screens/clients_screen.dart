import 'package:flutter/material.dart';
import 'package:app/controllers/client_controller.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late TextEditingController _searchController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _countsController;
  late TextEditingController _restaurantIdController;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _countsController = TextEditingController();
    _restaurantIdController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _countsController.dispose();
    _restaurantIdController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchCustomers() async {
    try {
      return await ClientController.fetchCustomers("", "");
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách khách hàng: $e');
    }
  }

  void _showCustomerDialog({int? customerId}) {
    final isEditing = customerId != null;

    if (!isEditing) {
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _countsController.clear();
      _restaurantIdController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Sửa khách hàng' : 'Thêm khách hàng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tên khách hàng'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
              ),
              TextField(
                controller: _countsController,
                decoration: InputDecoration(labelText: 'Số lượt đặt'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final customerName = _nameController.text.trim();
              final phoneNumber = _phoneController.text.trim();
              final counts = int.tryParse(_countsController.text.trim()) ?? 0;
              const restaurantId = 2;

              if (isEditing) {
                await _updateCustomer(customerId!, customerName, phoneNumber,
                    counts, restaurantId);
              } else {
                await _addCustomer(
                    customerName, phoneNumber, counts, restaurantId);
              }

              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(int customerId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Sửa'),
            onTap: () {
              Navigator.pop(context);
              _showCustomerDialog(customerId: customerId);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Xóa'),
            onTap: () {
              Navigator.pop(context);
              _deleteCustomer(customerId);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addCustomer(
      String name, String phone, int counts, int restaurantId) async {
    try {
      bool success = await ClientController.addCustomer(
        name,
        phone,
        counts,
        restaurantId,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thêm khách hàng thành công')));
        setState(() {});
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Thêm khách hàng thất bại')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _updateCustomer(int customerId, String name, String phone,
      int counts, int restaurantId) async {
    try {
      bool success = await ClientController.updateCustomer(
        customerId,
        name,
        phone,
        counts,
        restaurantId,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật khách hàng thành công')));
        setState(() {});
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Cập nhật thất bại')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _deleteCustomer(int customerId) async {
    try {
      bool success = await ClientController.deleteCustomer(customerId);
      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Xóa khách hàng thành công')));
        setState(() {});
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Xóa khách hàng thất bại')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông tin khách hàng',
          style: TextStyle(fontSize: 20, color: Color(0xFFEF4D2D)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCustomerDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm khách hàng',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20.0, // Tăng chiều cao thanh tìm kiếm
                  horizontal: 16.0,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchCustomers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có khách hàng nào.'));
                } else {
                  final customers = snapshot.data!
                      .where((customer) => customer['customer_name']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                  return ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final counts = customer['counts'] ?? 0; // Số lượt đặt
                      return GestureDetector(
                        onLongPress: () =>
                            _showOptionsDialog(customer['customer_id']),
                        child: ListTile(
                          title: Text(customer['customer_name']),
                          subtitle: Text(customer['phone_number']),
                          trailing: Icon(
                            Icons.favorite,
                            color: counts >= 5 ? Colors.red : Colors.grey,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
