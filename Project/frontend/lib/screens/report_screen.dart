import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:app/services/api_service.dart';
import 'package:app/controllers/report_controller.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, double> revenueData = {};
  Map<String, double> monthlyRevenueData = {};

  DateTime? selectedDate;
  final ReportController _reportController = ReportController(ApiService());
  List<String> days = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    days = getDaysForSelectedDate(selectedDate!); // Get 7 days near selected date
    _fetchRevenueData(); // Fetch revenue data on init
  }

  // Hàm lấy dữ liệu từ API
  Future<void> _fetchRevenueData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Lấy dữ liệu báo cáo doanh thu cho ngày đã chọn
      Map<String, double> data = await _reportController.fetchRevenueReportForSelectedDate(selectedDate!);
      setState(() {
        revenueData = data;
        // Lấy danh sách ngày tương ứng với dữ liệu
        days = getDaysForSelectedDate(selectedDate!); // Cập nhật lại danh sách ngày
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm lấy các ngày gần nhất (Dựa trên ngày đã chọn)
List<String> getDaysForSelectedDate(DateTime selectedDate) {
  List<String> days = [];
  // Bắt đầu từ selectedDate và thêm 6 ngày trước đó
  for (int i = 0; i < 7; i++) {
    DateTime targetDay = selectedDate.subtract(Duration(days: i)); // Trừ dần từ 0 đến 6
    days.add(DateFormat('dd/MM').format(targetDay));  // Định dạng ngày dưới dạng 'dd/MM'
  }
  return days;
}



Future<void> _fetchMonthlyRevenueData() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    Map<String, double> data = await _reportController.fetchMonthlyRevenue();
    setState(() {
      monthlyRevenueData = data;
    });
  } catch (e) {
    setState(() {
      _error = 'Lỗi khi tải dữ liệu doanh thu theo tháng: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  // Hàm chọn ngày
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDate: selectedDate!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
        days = getDaysForSelectedDate(picked); // Update days based on selected date
      });
      _fetchRevenueData(); // Fetch data for new date range
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
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: TextStyle(fontSize: 16, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : revenueData.isEmpty
                          ? Center(
                              child: Text(
                                'Không có dữ liệu để hiển thị.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : Container(
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
                                  maxY: revenueData.values.reduce((a, b) => a > b ? a : b),
                                  barGroups: _generateBarGroups(),
                                  gridData: FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Column(
                                            children: [
                                              Text(
                                                days[value.toInt()],
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
                                        showTitles: false,
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
  final List<double> barData = days.map((day) {
    // Nếu revenueData chứa ngày, trả về giá trị của nó, nếu không trả về 0.
    return revenueData.containsKey(day) ? revenueData[day]! : 0.0;
  }).toList();

  final String today = DateFormat('dd/MM').format(DateTime.now());
  //final NumberFormat currencyFormat = NumberFormat("#,##0.000", "en_US"); // Định dạng số với 3 chữ số sau dấu thập phân

  return List.generate(barData.length, (index) {
    bool isToday = days[index] == today;
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: barData[index],
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



