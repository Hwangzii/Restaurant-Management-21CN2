import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week; // Hiển thị tuần
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, double> dailyAmounts = {}; // Dữ liệu tổng hợp theo ngày
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData(); // Lấy dữ liệu khi khởi tạo
  }

  // Hàm lấy dữ liệu từ API
  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://457f-14-232-55-213.ngrok-free.app/api/invoice_food/'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        Map<DateTime, double> amounts = {};

        for (var item in data) {
          DateTime date = DateTime.parse(item['created_at'])
              .toLocal()
              .toUtc()
              .toLocal(); // Chuyển ngày từ API
          double totalAmount = double.parse(item['total_amount']);

          // Cập nhật dữ liệu tổng hợp theo ngày
          amounts.update(date, (value) => value + totalAmount,
              ifAbsent: () => totalAmount);
        }

        setState(() {
          dailyAmounts = amounts;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch và Thống Kê'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Lịch hiển thị chỉ một tuần
                    Container(
                      margin: EdgeInsets.all(8),
                      height: 300,
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            fetchData(); // Lấy dữ liệu cho ngày đã chọn
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        eventLoader: (day) {
                          if (dailyAmounts.containsKey(day)) {
                            return [dailyAmounts[day]!];
                          }
                          return [];
                        },
                      ),
                    ),
                    // Biểu đồ cột hiển thị tổng số tiền
                    Container(
                      margin: EdgeInsets.all(8),
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          barGroups: dailyAmounts.entries
                              .map((entry) => BarChartGroupData(
                                    x: entry.key.day,
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value / 1000, // Scale down
                                        color: Colors.blue,
                                        width: 10,
                                      )
                                    ],
                                  ))
                              .toList(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
