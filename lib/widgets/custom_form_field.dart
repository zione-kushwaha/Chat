import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField(
      {super.key,
      required this.hintText,
      required this.validateRegularExp,
      required this.onSaved,
      this.obscureText = false});
  final String hintText;
  final RegExp validateRegularExp;
  final bool obscureText;
  final void Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value != null && validateRegularExp.hasMatch(value)) {
          return null;
        } else {
          return 'Please enter a valid $hintText';
        }
      },
      obscureText: obscureText,
      onSaved: onSaved,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
