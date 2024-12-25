import 'package:flutter/material.dart';
import '../../models/user_settings.dart';
import '../../services/auth/password_service.dart';

class AccountSettingsSection extends StatelessWidget {
  final UserSettings settings;
  final Function(String) onEmailChanged;
  final Function(String, String) onPasswordChanged;
  final PasswordService passwordService;

  const AccountSettingsSection({
    required this.settings,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.passwordService,
  });

Future<void> _updateEmail(BuildContext context) async {
  final currentEmailController = TextEditingController(text: settings.email);
  final newEmailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? emailError;

  await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Update Email'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentEmailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Current Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: newEmailController,
                decoration: InputDecoration(
                  labelText: 'New Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'New email is required';
                  if (!value!.contains('@')) return 'Invalid email format';
                  if (value == settings.email) return 'New email must be different';
                  if (emailError != null) return emailError;
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final newEmail = newEmailController.text;
                final emailExists = await settings.doesEmailExist(newEmail);
                if (emailExists) {
                  setState(() {
                    emailError = 'Email already exists. Try another.';
                  });
                  formKey.currentState?.validate(); 
                  return;
                }

                final success = await settings.updateEmail(newEmail);
                if (success) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update email')),
                  );
                }
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    ),
  );
}

  Future<void> _changePassword(BuildContext context) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Current password is required';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'New password is required';
                  if (!passwordService.validatePassword(value!)) {
                    return 'Invalid password format.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  final success = await passwordService.updatePassword(
                    settings.email,
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  if (success) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Container(
                          width: double.infinity, // Set width to full
                          child: Text('Password updated successfully'),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Container(
                          width: double.infinity, // Set width to full
                          child: Text('Failed to update password'),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error updating password: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        width: double.infinity, // Set width to full
                        child: Text('An error occurred while updating password'),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT SETTINGS',
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
                leading: Icon(Icons.email, color: Colors.blue),
                title: Text('Update Email'),
                subtitle: Text(
                  settings.email.isEmpty ? 'Not set' : settings.email,
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _updateEmail(context),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.lock, color: Colors.blue),
                title: Text('Change Password'),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _changePassword(context),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await settings.clearUserData();   
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin',
        (route) => false,  
      );
    }
  }
}