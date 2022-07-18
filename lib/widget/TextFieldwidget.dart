import 'package:flutter/material.dart';

import 'my_colors.dart';

class TextFieldWidget extends StatelessWidget {
  final String? labelText;
  final icon;
  final bool obscureText;
  final suffixIcon;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final bool enabled;
  ValueChanged<String>? onChanged;
  TextFieldWidget(
      {required this.labelText,
      this.icon,
      this.enabled = true,
      this.onChanged,
      this.obscureText = false,
      this.suffixIcon,
      this.validator,
      this.controller,});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        enabled: enabled,
        labelText: labelText,
        labelStyle: const TextStyle(color: SolidColors.mainColor),
        filled: true,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: SolidColors.mainColor)),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: SolidColors.mainColor,
        ),
        suffixIcon: Icon(
          suffixIcon,
          size: 20,
          color: SolidColors.mainColor,
        ),
      ),
    );
  }
}
