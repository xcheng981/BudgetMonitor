import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';  
import '../../models/user_settings.dart';

class ProfileSection extends StatelessWidget {
  final UserSettings settings;
  final Function(String) onNameChanged;
  final Function(String) onAvatarChanged;

  const ProfileSection({
    required this.settings,
    required this.onNameChanged,
    required this.onAvatarChanged,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      onAvatarChanged(pickedFile.path);
    }
  }

  Future<void> _changeName(BuildContext context) async {
    final controller = TextEditingController(text: settings.userName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                onNameChanged(newName);
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: settings.avatarPath.isNotEmpty
                    ? FileImage(File(settings.avatarPath))
                    : null,
                child: settings.avatarPath.isEmpty
                    ? Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.userName.isEmpty ? 'Set your name' : settings.userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    settings.email,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _changeName(context),
            ),
          ],
        ),
      ),
    );
  }
}