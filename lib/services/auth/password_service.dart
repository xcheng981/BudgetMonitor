import '../database/database_helper.dart';

class PasswordService {
  final DatabaseHelper _dbHelper;

  PasswordService(this._dbHelper);

  // Password validation
  bool validatePassword(String password) {
    final passwordRegEx =
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    return RegExp(passwordRegEx).hasMatch(password);
  }

// Reset password (login page)
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      if (user != null) {
        return await _dbHelper.updateUserProfile(
          email,
          newPassword: newPassword,
        );
      }
      return false;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  // Update password (setting page)
  Future<bool> updatePassword(String email, String currentPassword, String newPassword) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      if (user != null && user['password'] == currentPassword) {
        return await _dbHelper.updateUserProfile(
          email,
          newPassword: newPassword,
        );
      }
      return false;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }
}