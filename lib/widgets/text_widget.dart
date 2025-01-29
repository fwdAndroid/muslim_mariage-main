import 'package:flutter/material.dart';
import 'package:muslim_mariage/utils/colors.dart';

void showAlert(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Widget buildTextField(
    String labelText, TextEditingController controller, IconData? icon,
    {int maxLines = 1}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: mainColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: mainColor),
      ),
      prefixIcon: icon != null ? Icon(icon) : null,
    ),
  );
}

Widget buildTextFieldNumber(
    String labelText, TextEditingController controller, IconData? icon,
    {int maxLines = 1}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: mainColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: mainColor),
      ),
      prefixIcon: icon != null ? Icon(icon) : null,
    ),
  );
}
