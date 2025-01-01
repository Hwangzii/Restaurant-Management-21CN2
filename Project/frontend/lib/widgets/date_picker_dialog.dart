import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DatePickerDialog extends StatefulWidget {
  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chọn Ngày'),
      content: SingleChildScrollView(
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // Update focused day
            });
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Color(0xFFF45211), // Màu sắc của ngày được chọn
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.orange, // Màu sắc của ngày hôm nay
              shape: BoxShape.circle,
            ),
            weekendTextStyle:
                TextStyle(color: Colors.black), // Màu của ngày cuối tuần
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false, // Ẩn nút đổi chế độ (ngày, tháng, năm)
            titleCentered: true, // Canh giữa tiêu đề
            titleTextStyle: TextStyle(
                color: Colors.black, fontSize: 18), // Màu và kiểu chữ tiêu đề
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Đóng dialog mà không làm gì
          },
          child: Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedDay); // Trả về ngày đã chọn
          },
          child: Text('Chọn'),
        ),
      ],
    );
  }
}
