import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_text_field.dart';

class ProfileUpdateScreen extends StatefulWidget {
  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  String? _gender;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _ageController = TextEditingController(text: user.age?.toString() ?? '');
    _gender = user.gender;
  }

  void _updateProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final updatedUser = User(
      name: _nameController.text,
      email: _emailController.text,
      password: userProvider.user!.password,
      age: int.tryParse(_ageController.text),
      gender: _gender,
      userId: userProvider.user!.userId,
    );
    userProvider.setUser(updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CustomTextField(
              labelText: 'Name',
              controller: _nameController,
              icon: Icons.person,
            ),
            CustomTextField(
              labelText: 'Email',
              controller: _emailController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,// Disable editing for email
            ),
            CustomTextField(
              labelText: 'Age',
              controller: _ageController,
              keyboardType: TextInputType.number,
              icon: Icons.cake,
            ),
            DropdownButtonFormField(
              value: _gender,
              decoration: InputDecoration(
                labelText: 'Gender',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ['Male', 'Female', 'Other']
                  .map((label) => DropdownMenuItem(
                        child: Text(label),
                        value: label,
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _gender = value as String?),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
