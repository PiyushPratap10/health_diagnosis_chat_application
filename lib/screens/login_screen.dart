import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/api_service.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final result = await apiService.signin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result != null) {
        final user = User(
            name: result['name'].toString(),
            email: result['email'].toString(),
            userId: result['user_id'].toString(),
            age: result['age'],
            gender: result['gender'].toString(),
            password: result['password'].toString());

        Provider.of<UserProvider>(context, listen: false).setUser(user);

        // Navigate to chat screen
        Navigator.pushReplacementNamed(context, '/chat');
        Fluttertoast.showToast(msg: "Login successful!");
      } else {
        Fluttertoast.showToast(
            msg: "Login failed. Please check your credentials.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, "/register");
                  },
                  child: const Text("Don't have an account? Register"))
            ],
          ),
        ),
      ),
    );
  }
}
