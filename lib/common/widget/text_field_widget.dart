// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lighthouse_buffet/core/resources/colors.dart';

// ignore: must_be_immutable
class MyTextFieldDialog extends StatelessWidget {
  TextEditingController? controller;
  final String labelText;
  final bool isPassword;
  final bool? readOnly;
  final bool? autofocus;
  
  List<TextInputFormatter>? inputFormatters;
  void Function()? onTap;
  void Function(String)? onChanged;
  void Function(String)? onSubmitted;
  MyTextFieldDialog({
    super.key,
    this.controller,
    required this.labelText,
    required this.isPassword,
    this.readOnly,
    this.autofocus,
    this.inputFormatters,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16.0), // Add spacing between fields
      child: TextField(
        controller: controller,
        inputFormatters: inputFormatters,
        obscureText: isPassword, // Toggle for password field
        readOnly: readOnly ?? false,
        onTap: onTap,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        style: const TextStyle(
            color: darkNavy), // Set text color to darkNavy
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: darkNavy),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: darkNavy, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.grey, width: 1.0,),
            borderRadius: BorderRadius.circular(12.0),
          ),
          fillColor: Colors.grey[200],
          filled: true,
        ),
        autofocus: autofocus??true,
      ),
    );
  }
}
