import 'package:flutter/material.dart';
import 'package:healthwise_ai/api/api_service.dart';
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
  final apiService = ApiService();
  bool updated = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _ageController = TextEditingController(text: user.age?.toString() ?? '');
    _gender = user.gender;
  }

  void _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final result = await apiService.updateUserProfile(
        userProvider.user!.userId!,
        _nameController.text,
        int.tryParse(_ageController.text)!,
        _gender!,
        _emailController.text);

    if (result!.isNotEmpty) {
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
      setState(() {
        updated = true;
      });
      if (updated) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      appBar: AppBar(title: Text('Update Profile',style: TextStyle(color: const Color.fromARGB(255, 39, 39, 39)),),centerTitle: true,backgroundColor: Color.fromARGB(255, 255, 223, 0),),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
            return Card(
              elevation: 4,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: width,
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  shrinkWrap: true,
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
                      keyboardType: TextInputType.emailAddress,
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
                      child: Text('Save Changes',style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                          shadowColor: null,
                          minimumSize: Size(200, 50),
                          maximumSize: Size(300, 50),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
