import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  // 添加这行
import 'screens/auth/splash_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/details_screen.dart';
import 'screens/add_record_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database/database_helper.dart';
import 'package:provider/provider.dart';
import 'services/shared/date_service.dart';
import 'models/user_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbHelper = DatabaseHelper();
  final prefs = await SharedPreferences.getInstance();
  
  final settings = UserSettings(dbHelper, prefs);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DateService()),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: MaterialApp(
        title: 'Budget App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/signin': (context) => SignInScreen(),
          '/signup': (context) => SignUpScreen(),
          '/reset-password': (context) => ResetPasswordScreen(),
          '/details': (context) => DetailsScreen(),
          '/add_record': (context) => AddRecordScreen(),
          '/analysis': (context) => AnalysisScreen(),
          '/settings': (context) => SettingsScreen(),
        },
      ),
    ),
  );
}