import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database/database_helper.dart';
import 'dart:io';  
import 'package:intl/intl.dart'; 

class UserSettings extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  final SharedPreferences _prefs;
  
  String _email = '';
  String _password = '';
  String _userName = '';
  String _avatarPath = '';
  int _monthStartDay = 1;
  String _currency = 'USD';
  int _decimalPlaces = 2;  

  DatabaseHelper get databaseHelper => _dbHelper;

  String formatAmount(double amount) {
    final currencySymbols = {
      'CNY': '¥',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
    };

    final symbol = currencySymbols[_currency] ?? '';
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: _decimalPlaces,  
    );

    try {
      return formatter.format(amount);
    } catch (e) {
      print('Error formatting amount: $e');
      return '$symbol${amount.toStringAsFixed(_decimalPlaces)}';   
    }
  }
  
  UserSettings(this._dbHelper, this._prefs) {
    _loadSettings();
  }

  String get email => _email;
  String get password => _password;
  String get userName => _userName;
  String get avatarPath => _avatarPath;
  int get monthStartDay => _monthStartDay;
  String get currency => _currency;
  int get decimalPlaces => _decimalPlaces;  

  Future<void> _loadSettings() async {
    _email = _prefs.getString('email') ?? '';
    _password = _prefs.getString('password') ?? '';
    _userName = _prefs.getString('userName') ?? '';
    _avatarPath = _prefs.getString('avatarPath') ?? '';
    _monthStartDay = _prefs.getInt('monthStartDay') ?? 1;
    _currency = _prefs.getString('currency') ?? 'USD';
    _decimalPlaces = _prefs.getInt('decimalPlaces') ?? 2;  
    notifyListeners();
  }

  Future<void> save() async {
    await _prefs.setString('email', _email);
    await _prefs.setString('password', _password);
    await _prefs.setString('userName', _userName);
    await _prefs.setString('avatarPath', _avatarPath);
    await _prefs.setInt('monthStartDay', _monthStartDay);
    await _prefs.setString('currency', _currency);
    await _prefs.setInt('decimalPlaces', _decimalPlaces);  
  }

  Future<void> setLoginInfo(String email, String password, {String? userName, String? avatarPath}) async {
    _email = email;
    _password = password;
    _userName = userName ?? '';
    _avatarPath = avatarPath ?? '';
    await save();
    notifyListeners();
  }

  // Update username
  Future<bool> updateUserName(String newName) async {
    try {
      final success = await _dbHelper.updateUserProfile(
        _email,
        userName: newName,
      );
      if (success) {
        _userName = newName;
        await save();
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error updating user name: $e');
      return false;
    }
  }

  // Update avatar
  Future<bool> updateAvatar(String newPath) async {
    try {
      final success = await _dbHelper.updateUserProfile(
        _email,
        avatarPath: newPath,
      );
      if (success) {
        _avatarPath = newPath;
        await save();
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error updating avatar: $e');
      return false;
    }
  }

  Future<bool> doesEmailExist(String email) async {
    try {
      return await _dbHelper.emailExists(email);
    } catch (e) {
      print('Error checking if email exists: $e');
      return false; 
    }
  }

  // Update email
  Future<bool> updateEmail(String newEmail) async {
    try {
      final success = await _dbHelper.updateUserProfile(
        _email,
        newEmail: newEmail,
      );
      if (success) {
        _email = newEmail;
        await save();
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error updating email: $e');
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      if (currentPassword != _password) return false;
      
      final success = await _dbHelper.updateUserProfile(
        _email,
        newPassword: newPassword,
      );
      if (success) {
        _password = newPassword;
        await save();
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  // Update start date
  void updateMonthStartDay(int day) {
    _monthStartDay = day;
    save();
    notifyListeners();
  }

  // Update currency
  void updateCurrency(String newCurrency) {
    _currency = newCurrency;
    save();
    notifyListeners();
  }

  // Update decimal places
  void updateDecimalPlaces(int places) {
    if (places >= 0 && places <= 4) {  
      _decimalPlaces = places;
      save();
      notifyListeners();
    }
  }

  Future<void> clearUserData() async {
    _email = '';
    _password = '';
    _userName = '';
    _avatarPath = '';
    await save();
    notifyListeners();
  }
}