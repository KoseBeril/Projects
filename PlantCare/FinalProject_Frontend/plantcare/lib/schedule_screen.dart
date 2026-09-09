import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'api_service.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

// Bu sınıf, takvim ekranını ve görevleri yönetir.
class _ScheduleScreenState extends State<ScheduleScreen> {
  final ApiService _apiService = ApiService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _tasks = [];
  String _selectedMode = "Daily";

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasksForDay(_selectedDay!);
  }

  // Belirli bir güne ait görevleri çek (Tarih formatı: YYYY-MM-DD)
  void _loadTasksForDay(DateTime day) async {
    String dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    final data = await _apiService.getTasksByDate(dateStr); // ApiService'e bu metodu ekle
    setState(() => _tasks = data);
  }

  String _formatDate(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // Kullanıcı arayüzünü oluştur (Schedule ekranı)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedules")),
      body: Column(
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: "Daily", label: Text("Daily")),
              ButtonSegment(value: "Weekly", label: Text("Weekly")),
            ],
            selected: {_selectedMode},
            onSelectionChanged: (newSelection) => setState(() => _selectedMode = newSelection.first),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadTasksForDay(selectedDay);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (ctx, i) => Card(
                child: ListTile(
                  title: Text(_tasks[i]['name']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _apiService.deleteTask(_tasks[i]['id']);
                      _loadTasksForDay(_selectedDay!);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewTask(_selectedDay!),
        child: Icon(Icons.add),
      ),
    );
  }
  
   // Yeni görev eklemek için modal bottom sheet açar
  Future<void> _addNewTask(DateTime selectedDate) async {
    String name = "";
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: "Plant Name"), onChanged: (v) => name = v),
            ElevatedButton(
              onPressed: () async {
                List<String> dates = [];
                if (_selectedMode == "Daily") {
                  dates.add(_formatDate(selectedDate));
                } else {
                  DateTimeRange? picked = await showDateRangePicker(
                      context: context, firstDate: DateTime.now(), lastDate: DateTime(2030));
                  if (picked != null) {
                    for (DateTime d = picked.start; !d.isAfter(picked.end); d = d.add(Duration(days: 1))) {
                      dates.add(_formatDate(d));
                    }
                  }
                }
                if (dates.isNotEmpty) {
                  await _apiService.addTasks(name, dates);
                  Navigator.pop(context);
                  _loadTasksForDay(_selectedDay!);
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}