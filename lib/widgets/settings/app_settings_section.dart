import 'package:flutter/material.dart';
import '../../models/user_settings.dart';

class AppSettingsSection extends StatelessWidget {
  final UserSettings settings;
  final Function(int) onMonthStartDayChanged;
  final Function(String) onCurrencyChanged;
  final Function(int) onDecimalChanged;

  const AppSettingsSection({
    Key? key,
    required this.settings,
    required this.onMonthStartDayChanged,
    required this.onCurrencyChanged,
    required this.onDecimalChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> currencyOptions = {
      'CNY': '¥',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'APP SETTINGS',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.blue),
                title: Text('Month Start Day'),
                trailing: DropdownButton<int>(
                  value: settings.monthStartDay,
                  items: List.generate(
                    28,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('${i + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) onMonthStartDayChanged(value);
                  },
                ),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.currency_exchange, color: Colors.blue),
                title: Text('Currency'),
                trailing: DropdownButton<String>(
                  value: settings.currency,
                  items: currencyOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text('${entry.value} (${entry.key})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) onCurrencyChanged(value);
                  },
                ),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.numbers, color: Colors.blue),  
                title: Text('Decimal Places'),
                trailing: DropdownButton<int>(
                  value: settings.decimalPlaces,
                  items: List.generate(
                    5,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(i == 0 ? 'No decimal' : '$i ${i == 1 ? 'place' : 'places'}'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) onDecimalChanged(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}