import 'package:flutter/material.dart';

Future<void> showWarningPopup({
  required BuildContext context,
  required String title,
  required List<Widget> content,
  List<Widget>? actions,
}) async {
  actions ??= [
    TextButton(
      child: const Text("Tamam"),
      onPressed: () => Navigator.of(context).pop(),
    )
  ];

  return await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: content,
          ),
        ),
        actions: actions,
      );
    },
  );
}
