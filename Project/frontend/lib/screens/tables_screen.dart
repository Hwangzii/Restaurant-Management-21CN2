import 'package:app/controllers/tables_controller.dart';
import 'package:flutter/material.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({Key? key}) : super(key: key);

  @override
  _TablesScreenState createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  String selectedFloor = 'Tầng 1'; // Mặc định là Tầng 1
  List<Map<String, dynamic>> tables = []; // Danh sách bàn rỗng ban đầu
  int? highlightedTableIndex; // Lưu trữ bàn được làm nổi bật
  bool isLoading = false;

  // Hàm để cập nhật danh sách bàn theo tầng
  void updateTables(String floor) async {
    setState(() {
      isLoading = true;
    });
    int floorNumber = 1; // Mặc định là tầng 1
    if (floor == 'Tầng 2') {
      floorNumber = 2;
    } else if (floor == 'Tầng 3') {
      floorNumber = 3;
    }

    // Gọi API để lấy danh sách bàn theo tầng
    List<Map<String, dynamic>> fetchedTables =
        await TablesController.fetchTables(floorNumber);

    setState(() {
      selectedFloor = floor;
      tables = fetchedTables; // Cập nhật danh sách bàn
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    updateTables(
        selectedFloor); // Gọi hàm để tải bàn mặc định khi màn hình khởi tạo
  }

  void _showOptionsMenu(BuildContext context, String tableName, int index) {
    setState(() {
      highlightedTableIndex = index; // Làm nổi bật bàn được chọn
    });

    int tableId = tables[index]['table_id'];

    // Hiển thị menu dưới dạng modal bottom sheet
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Làm mờ nền
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Sửa'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, tableId, tableName);
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
          ),
        );
      },
    ).whenComplete(() {
      // Khi modal đóng, bỏ nổi bật bàn
      setState(() {
        highlightedTableIndex = null;
      });
    });
  }

  void _showEditDialog(BuildContext context, int tableId, String currentName) {
    TextEditingController nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Sửa tên bàn'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Nhập tên mới cho bàn',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  _updateTableName(tableId, newName);
                }
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _updateTableName(int tableId, String newName) async {
    setState(() {
      isLoading = true;
    });
    bool success = await TablesController.updateTableName(tableId, newName);
    if (success) {
      // Cập nhật tên bàn trong danh sách hiện tại
      setState(() {
        int index = tables.indexWhere((table) => table['table_id'] == tableId);
        if (index != -1) {
          tables[index]['table_name'] = newName;
        }
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Không thể cập nhật tên bàn. Vui lòng thử lại.')),
      );
    }
  }

  void _deleteTable(int tableId) async {
    setState(() {
      isLoading = true;
    });
    bool success = await TablesController.deleteTable(tableId);
    if (success) {
      // Xóa bàn khỏi danh sách
      setState(() {
        tables.removeWhere((table) => table['table_id'] == tableId);
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa bàn thành công')),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa bàn. Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset('assets/angle-left.png', width: 24, height: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: DropdownButton<String>(
          dropdownColor: Colors.white,
          value: selectedFloor,
          onChanged: (String? newValue) {
            setState(() {
              selectedFloor = newValue!;
            });
            updateTables(
                selectedFloor); // Cập nhật lại danh sách bàn khi chọn tầng mới
          },
          items: <String>['Tầng 1', 'Tầng 2', 'Tầng 3']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings), // Thêm icon bạn muốn hiển thị
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
                if (value != null) {
                  print('Chọn $value');
                  // Thực hiện logic thêm bàn mới hoặc chọn nhiều bàn
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Color(0xFFF2F3F4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : tables.isEmpty
                      ? Center(child: Text('Không có bàn nào.'))
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: tables.length,
                          itemBuilder: (context, index) {
                            String tableName = tables[index]['table_name'];
                            bool isHighlighted = highlightedTableIndex == index;
                            return GestureDetector(
                              onTap: () {
                                print("Bàn $tableName được chọn");
                              },
                              onLongPress: () {
                                _showOptionsMenu(context, tableName, index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isHighlighted
                                      ? Colors.blue.withOpacity(0.3)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: isHighlighted
                                      ? Border.all(color: Colors.blue, width: 2)
                                      : Border.all(
                                          color: Colors.transparent, width: 0),
                                ),
                                child: Center(
                                  child: Text(
                                    tableName,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
