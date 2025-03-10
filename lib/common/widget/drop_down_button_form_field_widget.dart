// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:lighthouse_buffet/core/resources/colors.dart';

// ignore: must_be_immutable
class MyDropdownButtonFormField extends StatelessWidget {
  String selectedValue;
  String labelText;
  ValueChanged<String?> onChanged;
  List<DropdownMenuItem<String>> items;
  MyDropdownButtonFormField({
    super.key,
    required this.selectedValue,
    required this.labelText,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16.0), // Add spacing between fields
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: darkNavy), // Label color
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: darkNavy, width: 2.0), // Border when focused
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.grey, width: 1.0), // Border when not focused
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          fillColor: Colors.grey[200], // Background color of the dropdown field
          filled: true, // Enable the background fill
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
