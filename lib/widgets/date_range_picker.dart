import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime, DateTime) onDateRangeSelected;

  const DateRangePicker({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
  }) : super(key: key);

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  late DateTime _currentMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.startDate.year, widget.startDate.month);
    _rangeStart = widget.startDate;
    _rangeEnd = widget.endDate;
  }

  void _showCustomDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month - 1,
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map((day) => Text(
                            day,
                            style: TextStyle(color: Colors.grey),
                          ))
                      .toList(),
                ),
                SizedBox(height: 10),
                Container(
                  height: 300,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: 42,
                    itemBuilder: (context, index) {
                      final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
                      final firstWeekday = firstDayOfMonth.weekday % 7;
                      final day = index - firstWeekday + 1;

                      if (day < 1 || day > DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day) {
                        return Container(); 
                      }

                      final currentDate = DateTime(_currentMonth.year, _currentMonth.month, day);
                      final isFutureDate = currentDate.isAfter(DateTime.now());
                      final isInRange = _isInRange(currentDate);
                      final isRangeStart = _isStartDate(currentDate);
                      final isRangeEnd = _isEndDate(currentDate);

                      return InkWell(
                        onTap: isFutureDate
                            ? null 
                            : () {
                                setState(() {
                                  if (_rangeStart == null || _rangeEnd != null) {
                                    _rangeStart = currentDate;
                                    _rangeEnd = null;
                                  } else {
                                    if (currentDate.isBefore(_rangeStart!)) {
                                      _rangeEnd = _rangeStart;
                                      _rangeStart = currentDate;
                                    } else {
                                      _rangeEnd = currentDate;
                                    }
                                  }
                                });
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isRangeStart || isRangeEnd
                                ? Colors.teal
                                : isInRange
                                    ? Colors.teal.withOpacity(0.3)
                                    : null,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: TextStyle(
                                color: isFutureDate
                                    ? Colors.grey 
                                    : (isRangeStart || isRangeEnd || isInRange)
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: (isRangeStart || isRangeEnd)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Confirm'),
                        onPressed: () {
                          if (_rangeStart != null && _rangeEnd != null) {
                            widget.onDateRangeSelected(_rangeStart!, _rangeEnd!);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isInRange(DateTime date) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return date.isAfter(_rangeStart!) && date.isBefore(_rangeEnd!);
  }

  bool _isStartDate(DateTime date) {
    if (_rangeStart == null) return false;
    return date.year == _rangeStart!.year &&
           date.month == _rangeStart!.month &&
           date.day == _rangeStart!.day;
  }

  bool _isEndDate(DateTime date) {
    if (_rangeEnd == null) return false;
    return date.year == _rangeEnd!.year &&
           date.month == _rangeEnd!.month &&
           date.day == _rangeEnd!.day;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _showCustomDatePicker(context),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                '${DateFormat('MMM dd').format(_rangeStart ?? DateTime.now())} - '
                '${DateFormat('MMM dd').format(_rangeEnd ?? DateTime.now())}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
