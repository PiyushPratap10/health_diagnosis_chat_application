import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_service.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatelessWidget {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  String? _gender;

  RegisterScreen({super.key});

  void _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final result = await apiService.signup(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        int.parse(_ageController.text),
        _gender!,
      );

      try {
        if (result!.isNotEmpty) {
          final user = User(
            name: result['name'].toString(),
            email: result['email'].toString(),
            password: result['password'].toString(),
            userId: result['user_id'].toString(),
            age: result['age'],
            gender: result['gender'].toString(),
          );
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        labelText: 'Name',
                        controller: _nameController,
                        icon: Icons.person,
                      ),
                      CustomTextField(
                        labelText: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                        validator: Validators.validateEmail,
                      ),
                      CustomTextField(
                        labelText: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        icon: Icons.lock,
                        validator: Validators.validatePassword,
                      ),
                      CustomTextField(
                        labelText: 'Age',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        icon: Icons.cake,
                      ),
                      DropdownButtonFormField(
                        value: "Male",
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
                        onChanged: (value) => _gender = value as String,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _register(context),
                        child: Text('Register',style: TextStyle(color: Colors.white),),
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
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/login');
                        },
                        child: const Text("Already have an account? Login",style: TextStyle(color: const Color.fromARGB(255, 39, 39, 39)),),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
