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

Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required List<Widget> content,
}) async {
  bool response = false;

  final actions = [
    TextButton(
      child: const Text("Hayır"),
      onPressed: () {
        response = false;
        Navigator.of(context).pop();
      },
    ),
    TextButton(
      child: const Text("Evet"),
      onPressed: () {
        response = true;
        Navigator.of(context).pop();
      },
    ),
  ];

  await showDialog<void>(
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

  return response;
}
