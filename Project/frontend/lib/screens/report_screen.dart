import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<double> revenueData = [0.5, 1.2, 3.8, 0.9, 0.7, 1.3, 0.6];
  List<String> days = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    days = getDaysForSelectedDate(selectedDate!);
  }

  List<String> getDaysForSelectedDate(DateTime selectedDate) {
    DateTime startOfWeek = selectedDate.subtract(
      Duration(days: (selectedDate.weekday - DateTime.monday) % 7),
    );
    List<String> days = [];
    for (int i = 0; i < 7; i++) {
      DateTime targetDay = startOfWeek.add(Duration(days: i));
      days.add(DateFormat('dd/MM').format(targetDay));
    }
    return days;
  }

  

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDate: selectedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Bo góc = 10px
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        days = getDaysForSelectedDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text('Báo cáo bán hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Doanh thu tuần này',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                ElevatedButton(
                  onPressed: _pickDate, // Hiển thị DatePicker
                  child: Text('Chọn ngày'),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (selectedDate != null)
              Text(
                'Ngày chọn: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1, offset: Offset(0, 5)),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    maxY: 4,
                    barGroups: _generateBarGroups(),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            DateTime startOfWeek = selectedDate!.subtract(
                              Duration(days: (selectedDate!.weekday - DateTime.monday) % 7),
                            );
                            DateTime targetDate =
                                startOfWeek.add(Duration(days: value.toInt()));

                            return Column(
                              children: [
                                
                                Text(
                                  DateFormat('dd/MM').format(targetDate),
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            );
                          },
                          reservedSize: 50,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()} tr',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            );
                          },
                          reservedSize: 32,
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    final String today = DateFormat('dd/MM').format(DateTime.now());

    return List.generate(revenueData.length, (index) {
      bool isToday = days[index] == today;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: revenueData[index],
            color: isToday ? Color(0xFFFF8A00) : Color(0xFFFFD7A9),
            width: 16,
            borderSide: BorderSide(color: Colors.black12, width: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }
}
