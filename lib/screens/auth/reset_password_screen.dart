import 'package:flutter/material.dart';
import '../../services/auth/password_service.dart';
import '../../services/database/database_helper.dart';
import 'password_updated_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final PasswordService passwordService = PasswordService(DatabaseHelper());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final newPassword = newPasswordController.text;

                if (email.isEmpty || newPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        width: double.infinity, // Set width to full
                        child: Text('Please enter both email and new password'),
                      ),
                    ),
                  );
                  return;
                }

                if (!passwordService.validatePassword(newPassword)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        width: double.infinity, // Set width to full
                        child: Text('Password must be at least 8 characters with letter, number, and symbol'),
                      ),
                    ),
                  );
                  return;
                }

                try {
                  final success = await passwordService.resetPassword(email, newPassword);
                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordUpdatedScreen(
                          title: 'Password Reset!',
                          message: 'Your password has been reset successfully.',
                          buttonText: 'BACK TO LOGIN',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Container(
                          width: double.infinity, // Set width to full
                          child: Text('Email not found!'),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        width: double.infinity, // Set width to full
                        child: Text('An error occurred. Please try again.'),
                      ),
                    ),
                  );
                }
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
