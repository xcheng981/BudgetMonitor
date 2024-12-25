import 'package:flutter/material.dart';

class DateService extends ChangeNotifier {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  void setDateRange(DateTime start, DateTime? end) {
    _startDate = start;
    if (end != null) {
      _endDate = end;
    }
    notifyListeners();
  }
}