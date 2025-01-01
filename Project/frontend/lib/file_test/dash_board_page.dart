import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dashboard_controller.dart'; // Import Controller

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late List<BarChartData> _barChartData;
  late DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier([]);
    _controller = DashboardController();
    _barChartData = []; // Initialize as empty list

    // Fetch data from API
    _fetchData();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // Fetch and update data from API
  void _fetchData() async {
    try {
      List<BarChartData> fetchedData = await _controller.fetchInvoiceData();
      setState(() {
        _barChartData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<BarChartData> getSevenDaysData(DateTime selectedDate) {
    DateTime startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 5));

    return _barChartData
        .where((data) =>
            data.date.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
            data.date.isBefore(endOfWeek.add(Duration(days: 1))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(10),
              color: Colors.blue,
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    '7-Day Chart for Week of ${_selectedDay.toLocal()}',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: getSevenDaysData(_selectedDay).length,
                      itemBuilder: (context, index) {
                        BarChartData data =
                            getSevenDaysData(_selectedDay)[index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          width: 10,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${data.value}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              Container(
                                height: data.value.toDouble(),
                                color: Colors.orange,
                                width: 30,
                              ),
                              Text(
                                '${data.date.day}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(10),
              color: Colors.white,
              width: double.infinity,
              child: Center(
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 01, 01),
                  lastDay: DateTime.utc(2025, 12, 31),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: _getEventsForDay,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    return [];
  }
}

class BarChartData {
  final DateTime date;
  final int value;

  BarChartData({required this.date, required this.value});
}

class Event {
  final String title;
  Event({required this.title});
}
