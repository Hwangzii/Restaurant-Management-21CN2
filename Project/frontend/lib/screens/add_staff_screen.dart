import 'package:flutter/material.dart';
import 'package:app/controllers/list_staff_controller.dart';

class AddStaffScreen extends StatefulWidget {
  final Map<String, dynamic>? employee;

  const AddStaffScreen({Key? key, this.employee}) : super(key: key);

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _restaurantController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!['full_name'] ?? '';
      _phoneController.text = widget.employee!['phone_number'] ?? '';
      _birthController.text = widget.employee!['date_of_birth'] ?? '';
      _addressController.text = widget.employee!['employees_address'] ?? '';
      _positionController.text = widget.employee!['position'] ?? '';
      _cccdController.text = widget.employee!['cccd'] ?? '';
      _restaurantController.text =
          widget.employee!['restaurant_id'].toString() ?? '';
    }
  }

  void _saveStaff() async {
    // Kiểm tra và chuyển đổi dateOfBirth
    DateTime dateOfBirth;
    try {
      dateOfBirth =
          DateTime.parse(_birthController.text); // Convert text to DateTime
    } catch (e) {
      _showErrorMessage('Ngày sinh không hợp lệ!');
      return; // Stop if dateOfBirth is invalid
    }

    // Kiểm tra và chuyển đổi restaurant
    int restaurant;
    try {
      restaurant =
          int.tryParse(_restaurantController.text) ?? -1; // Ensure it's not 0
    } catch (e) {
      _showErrorMessage('ID Nhà hàng không hợp lệ!');
      return; // Stop if restaurant ID is invalid
    }

    if (restaurant == -1) {
      _showErrorMessage('ID nhà hàng không hợp lệ!');
      return; // Stop if restaurant ID is invalid
    }

    // Thêm thời gian bắt đầu (time_start)
    DateTime timeStart = DateTime.now(); // Use current time for timeStart

    bool success;
    if (widget.employee == null) {
      // Add new employee
      success = await ListStaffController.addStaff(
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        dateOfBirth:
            dateOfBirth, // Pass dateOfBirth as formatted string (yyyy-MM-dd)
        address: _addressController.text,
        position: _positionController.text,
        cccd: _cccdController.text,
        timeStart: timeStart, // Pass timeStart as formatted string (yyyy-MM-dd)
        statusWork: true,
        restaurant: restaurant, // Pass restaurant ID as int
      );
    } else {
      // Update employee
      success = await ListStaffController.updateStaff(
        employeeId: widget.employee!['employees_id'],
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        dateOfBirth:
            dateOfBirth, // Pass dateOfBirth as formatted string (yyyy-MM-dd)
        address: _addressController.text,
        position: _positionController.text,
        cccd: _cccdController.text,
        timeStart: timeStart, // Pass timeStart as formatted string (yyyy-MM-dd)
        statusWork: true,
        restaurant: restaurant, // Pass restaurant ID as int
      );
    }

    if (success) {
      print(widget.employee == null
          ? 'Thêm nhân viên thành công'
          : 'Cập nhật thông tin thành công');
      Navigator.pop(context, true); // Return and notify update is needed
    } else {
      print(widget.employee == null
          ? 'Thêm nhân viên thất bại'
          : 'Cập nhật thông tin thất bại');
    }
  }

  // Hàm hiển thị thông báo lỗi
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.employee == null
              ? 'Thêm nhân viên mới'
              : 'Sửa thông tin nhân viên')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputField('Họ và tên', _nameController),
            _buildInputField('Số điện thoại', _phoneController),
            _buildInputField('Ngày sinh', _birthController),
            _buildInputField('Địa chỉ', _addressController),
            _buildInputField('Chức vụ', _positionController),
            _buildInputField('CCCD', _cccdController),
            _buildInputField('ID Nhà hàng', _restaurantController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveStaff,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                widget.employee == null
                    ? 'Thêm nhân viên'
                    : 'Cập nhật thông tin',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
