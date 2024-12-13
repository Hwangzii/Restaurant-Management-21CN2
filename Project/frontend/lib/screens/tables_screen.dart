import 'package:flutter/material.dart';
import 'package:app/controllers/tables_controller.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({Key? key}) : super(key: key);

  @override
  _TablesScreenState createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  String selectedFloor = 'Tầng 1'; // Default floor
  List<Map<String, dynamic>> tables = []; // List of tables
  bool isLoading = false; // Loading state

  Map<String, int> floorMap = {
    'Tầng 1': 1,
    'Tầng 2': 2,
    'Tầng 3': 3,
  };

  @override
  void initState() {
    super.initState();
    _updateTables(selectedFloor);
  }

  // Fetch tables based on selected floor
  void _updateTables(String floor) async {
    setState(() {
      isLoading = true;
    });

    int floorNumber = floorMap[floor] ?? 1;

    try {
      List<Map<String, dynamic>> fetchedTables = await TablesController.fetchTables(floorNumber);
      setState(() {
        selectedFloor = floor;
        tables = fetchedTables;
      });
    } catch (e) {
      _showErrorSnackBar('Không thể tải danh sách bàn. Vui lòng thử lại.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Reload tables (wrapper function for _updateTables)
  void reloadTables() {
    _updateTables(selectedFloor);
  }

  // Show options for table
  void _showOptionsMenu(BuildContext context, String tableName, int tableId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Sửa'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, tableName, tableId);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Xóa'),
              onTap: () {
                Navigator.pop(context);
                _deleteTable(tableId);
              },
            ),
          ],
        );
      },
    );
  }

  // Show edit dialog
  void _showEditDialog(BuildContext context, String currentName, int tableId) {
    TextEditingController nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Sửa tên bàn'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Nhập tên mới cho bàn'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(dialogContext);

                  // Gọi phương thức trung gian để cập nhật tên bàn
                  try {
                    bool success = await _updateTableName(tableId, newName);
                    if (success) {
                      reloadTables(); // Call reloadTables
                      _showSuccessSnackBar('Cập nhật tên bàn thành công');
                    } else {
                      _showErrorSnackBar('Không thể cập nhật tên bàn');
                    }
                  } catch (e) {
                    _showErrorSnackBar('Lỗi khi cập nhật tên bàn');
                  }
                }
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

// Phương thức trung gian để gọi vào controller
Future<bool> _updateTableName(int tableId, String newName) async {
  try {
    bool success = await TablesController.updateTableName(tableId, newName, floorMap[selectedFloor]!);
    return success;
  } catch (e) {
    return false;
  }
}


  // Show add table dialog
void _showAddTableDialog() {
  TextEditingController nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text('Thêm tên bàn'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: 'Nhập tên bàn mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              String newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(dialogContext);

                // Gọi phương thức trung gian để thêm bàn
                try {
                  bool success = await _addTable(newName);
                  if (success) {
                    reloadTables(); // Call reloadTables
                    _showSuccessSnackBar('Thêm bàn thành công');
                  } else {
                    _showErrorSnackBar('Không thể thêm bàn');
                  }
                } catch (e) {
                  _showErrorSnackBar('Lỗi khi thêm bàn');
                }
              }
            },
            child: Text('Xác nhận'),
          ),
        ],
      );
    },
  );
}

// Phương thức trung gian để gọi vào controller
Future<bool> _addTable(String newName) async {
  try {
    bool success = await TablesController.addTable(newName, floorMap[selectedFloor]!);
    return success;
  } catch (e) {
    return false;
  }
}


  // Delete table
  void _deleteTable(int tableId) async {
    setState(() {
      isLoading = true;
    });

    try {
      bool success = await TablesController.deleteTable(tableId);
      if (success) {
        reloadTables(); // Call reloadTables
        _showSuccessSnackBar('Xóa bàn thành công');
      } else {
        _showErrorSnackBar('Không thể xóa bàn');
      }
    } catch (e) {
      _showErrorSnackBar('Không thể xóa bàn');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show error snack bar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Show success snack bar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: selectedFloor,
          onChanged: (String? newValue) {
            setState(() {
              selectedFloor = newValue!;
            });
            _updateTables(selectedFloor);
          },
          items: ['Tầng 1', 'Tầng 2', 'Tầng 3']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100.0, 100.0, 0.0, 0.0),
                items: [
                  PopupMenuItem<String>(
                    value: 'them_ban',
                    child: Text('Thêm bàn mới'),
                  ),
                  PopupMenuItem<String>(
                    value: 'chon_nhieu_ban',
                    child: Text('Chọn nhiều bàn'),
                  ),
                ],
                elevation: 8.0,
              ).then((value) {
                if (value == 'them_ban') {
                  _showAddTableDialog();
                } else if (value == 'chon_nhieu_ban') {
                  print('Chọn nhiều bàn');
                  // Thêm logic xử lý chọn nhiều bàn
                }
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 15.0,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                String tableName = tables[index]['table_name'] ?? 'Chưa có tên';
                return GestureDetector(
                  onLongPress: () => _showOptionsMenu(context, tableName, tables[index]['table_id']),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 2.0,
                    child: Center(
                      child: Text(
                        tableName,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
