import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../widgets/settings/profile_section.dart';
import '../widgets/settings/app_settings_section.dart';
import '../widgets/settings/account_settings_section.dart';
import '../services/auth/password_service.dart';
import '../services/database/database_helper.dart';
import '../widgets/shared/bottom_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  final dbHelper = DatabaseHelper();
  late final passwordService = PasswordService(dbHelper);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UserSettings>();

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile
            ProfileSection(
              settings: settings,
              onNameChanged: (newName) => settings.updateUserName(newName),
              onAvatarChanged: (newPath) => settings.updateAvatar(newPath),
            ),
            SizedBox(height: 32),
            
            // App setting
            AppSettingsSection(
              settings: settings,
              onMonthStartDayChanged: (value) => settings.updateMonthStartDay(value),
              onCurrencyChanged: (value) => settings.updateCurrency(value),
              onDecimalChanged: (value) => settings.updateDecimalPlaces(value),
            ),
            SizedBox(height: 32),
            
            // Account setting
            AccountSettingsSection(
              settings: settings,
              passwordService: passwordService,
              onEmailChanged: (newEmail) => settings.updateEmail(newEmail),
              onPasswordChanged: (current, newPass) => settings.updatePassword(current, newPass),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/details');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/analysis');
          }
        },
      ),
    );
  }
}