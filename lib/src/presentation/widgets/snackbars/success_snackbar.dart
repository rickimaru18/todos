import 'package:flutter/material.dart';

void showSuccessSnackBar(BuildContext context, String error) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        error,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );
}
