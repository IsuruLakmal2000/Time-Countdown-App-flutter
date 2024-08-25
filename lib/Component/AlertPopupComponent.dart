import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget AlertPopupComponent({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onOkPressed,
}) {
  return Stack(
    children: [
      AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              onOkPressed();
            },
            child: const Text('OK'),
          ),
        ],
      ),
      Positioned(
        top: MediaQuery.of(context).size.height / 2 - 150,
        right: MediaQuery.of(context).size.width / 2 - 135,
        child: Lottie.asset(
          'assets/lottie/warning.json', // Path to your Lottie file
          width: 100, // Adjust the width as needed
          height: 100, // Adjust the height as needed
          fit: BoxFit.fill,
        ),
      ),
    ],
  );
}
