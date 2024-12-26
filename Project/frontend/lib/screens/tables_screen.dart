import 'package:app/controllers/oder_food_controller.dart';
import 'package:app/screens/order_food_screen.dart';
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
    await TablesController.updateAllTableStatuses();
    int floorNumber = floorMap[floor] ?? 1;

    try {
      List<Map<String, dynamic>> fetchedTables =
          await TablesController.fetchTables(floorNumber);
      // Sắp xếp danh sách bàn theo tên
      fetchedTables.sort((a, b) {
        String nameA = a['table_name']?.toLowerCase() ?? '';
        String nameB = b['table_name']?.toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });
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
  // Reload tables (wrapper function for _updateTables)
  void reloadTables() async {
    setState(() {
      isLoading = true;
    });

    try {
      // // Duyệt qua từng bàn và kiểm tra/cập nhật trạng thái
      // for (var table in tables) {
      //   String tableName = table['table_name'];
      //   await OrderFoodController.checkAndUpdateTableStatus(tableName);
      // }

      // Làm mới danh sách bàn sau khi cập nhật trạng thái
      _updateTables(selectedFloor);
    } catch (e) {
      _showErrorSnackBar(
          'Không thể cập nhật trạng thái bàn. Vui lòng thử lại.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
    TextEditingController nameController =
        TextEditingController(text: currentName);

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
      bool success = await TablesController.updateTableName(
          tableId, newName, floorMap[selectedFloor]!);
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
      bool success =
          await TablesController.addTable(newName, floorMap[selectedFloor]!);
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Show success snack bar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Phương thức cập nhật để hiển thị menu lựa chọn khi nhấn chuột phải vào bàn
  void _showTableOptions(BuildContext context, String tableName, int tableId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text('Bàn $tableName', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Image.asset(
                  'assets/steak.png', // Đường dẫn đến hình ảnh
                  width: 20, // Chiều rộng của hình ảnh
                  height: 20, // Chiều cao của hình ảnh
                  fit: BoxFit.contain, // Cách căn chỉnh hình ảnh trong widget
                ),
                title: Text('Buffet đỏ'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _handleOptionSelection('Buffet đỏ', tableId);
                },
              ),
              ListTile(
                leading: Image.asset(
                  'assets/seafood.png', // Đường dẫn đến hình ảnh
                  width: 20, // Chiều rộng của hình ảnh
                  height: 20, // Chiều cao của hình ảnh
                  fit: BoxFit.contain, // Cách căn chỉnh hình ảnh trong widget
                ),
                title: Text('Buffet đen'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _handleOptionSelection('Buffet đen', tableId);
                },
              ),
              ListTile(
                leading: Image.asset(
                  'assets/food.png', // Đường dẫn đến hình ảnh
                  width: 20, // Chiều rộng của hình ảnh
                  height: 20, // Chiều cao của hình ảnh
                  fit: BoxFit.contain, // Cách căn chỉnh hình ảnh trong widget
                ),
                title: Text('Gọi món'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _handleOptionSelection('Gọi món', tableId);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Đóng dialog
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  // **THAY ĐỔI**: Phương thức xử lý khi chọn Buffet đỏ hoặc Buffet đen
  // Xử lý khi chọn 1 trong các lựa chọn (Buffet đỏ, Buffet đen, Gọn món)
  void _handleOptionSelection(String option, int tableId) {
    String tableName = tables
        .firstWhere((table) => table['table_id'] == tableId)['table_name'];

    if (option == 'Buffet đỏ' || option == 'Buffet đen') {
      _showGuestCountDialog(option, tableId, tableName);
    } else if (option == 'Gọi món') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderFoodScreen(
            tableName: tableName,
            selectedType: 'Gọi món', // Hiển thị tất cả các loại món
            guestCount: 0, // Không cần số lượng khách
            buffetTotal: 0,
            onUpdate: () {
              print('Cập nhật từ OrderFoodScreen!');
              reloadTables(); // Gọi hàm cập nhật danh sách bàn
            },
          ),
        ),
      );
    }
  }

// Cập nhật _showGuestCountDialog để truyền guestCount
  void _showGuestCountDialog(String option, int tableId, String tableName) {
    TextEditingController guestCountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text('Nhập số lượng khách cho $option'),
          content: TextField(
            controller: guestCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Nhập số lượng khách'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                String guestCountText = guestCountController.text.trim();
                int guestCount = int.tryParse(guestCountText) ?? 0;

                if (guestCount > 1) {
                  Navigator.pop(dialogContext); // Đóng dialog

                  // Giá buffet cho từng loại
                  int buffetPrice = option == 'Buffet đỏ' ? 500000 : 550000;

                  // Tính tổng giá trị Buffet
                  int buffetTotal = buffetPrice;

                  // Chuyển sang OrderFoodScreen với giá trị Buffet đã tính toán
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderFoodScreen(
                        tableName: tableName,
                        selectedType: option,
                        guestCount: guestCount,
                        buffetTotal: buffetTotal, // Truyền tổng giá trị Buffet
                        onUpdate: () {
                          // Gọi hàm cập nhật trạng thái trong `TablesScreen`
                          reloadTables();
                        },
                      ),
                    ),
                  );
                } else {
                  _showErrorSnackBar('Số lượng khách phải lớn hơn 1');
                }
              },
              child: Text('Xác nhận'),
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
            icon: Icon(Icons.menu),
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
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 1.0,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                String tableName = tables[index]['table_name'] ?? 'Chưa có tên';
                int status = (tables[index]['status'] is bool)
                    ? (tables[index]['status']
                        ? 1
                        : 0) // Nếu là bool, chuyển thành int
                    : (tables[index]['status'] ??
                        0); // Nếu null, gán giá trị mặc định là 0

                Color cardColor =
                    (status == 1) ? Color(0xFFFF8A00) : Color(0xFFF2F2F7);

                return GestureDetector(
                  onTap: () async {
                    // Kiểm tra trạng thái của bàn
                    bool tableStatus = tables[index]['status'] ?? false;

                    if (tableStatus) {
                      Map<String, dynamic> buffetStatus =
                          await OrderFoodController.hasBuffet(tableName);

                      bool hasBuffet = buffetStatus['has_buffet'];
                      String buffetName = buffetStatus['buffet_name'];
                      // Debug thông tin Buffet
                      print("Buffet Status: $hasBuffet");
                      print("Buffet Name: $buffetName");

                      // Nếu status là true, điều hướng tới OrderFoodScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderFoodScreen(
                            tableName: tableName,
                            selectedType: hasBuffet ? buffetName : "Tất cả", //
                            guestCount: 0,
                            buffetTotal: 0,
                            onUpdate:
                                reloadTables, // Callback để reload danh sách bàn
                          ),
                        ),
                      );
                    } else {
                      // Nếu status là false, hiển thị showTableOptions
                      _showTableOptions(
                          context, tableName, tables[index]['table_id']);
                    }
                  },
                  onLongPress: () => _showOptionsMenu(
                    context,
                    tableName,
                    tables[index]['table_id'],
                  ),
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0.0,
                    child: Center(
                      child: Text(
                        tableName,
                        style: TextStyle(
                          fontSize: 16.0,
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
