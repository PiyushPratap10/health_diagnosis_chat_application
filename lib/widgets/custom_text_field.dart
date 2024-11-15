import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? icon;
  final String? Function(String?)? validator;
  

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelStyle: TextStyle(color:const Color.fromARGB(255, 39, 39, 39) ),
          labelText: labelText,
          prefixIcon: icon != null ? Icon(icon, color: const Color.fromARGB(255, 39, 39, 39)) : null,
          filled: true,
          fillColor: Colors.grey[150],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: const Color.fromARGB(255, 39, 39, 39), width: 1.5),
          ),
        ),
      ),
    );
  }
}
