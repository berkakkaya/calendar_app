import 'package:flutter/material.dart';

Future<DateTime?> getDate(BuildContext context) async {
  final now = DateTime.now();

  return await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365 * 5)),
    helpText: "Tarih seçin",
    cancelText: "İptal et",
    confirmText: "Kaydet",
    errorFormatText: "Geçersiz tarih formatı",
    errorInvalidText: "Geçersiz tarih girişi",
    fieldLabelText: "Tarih",
  );
}

Future<TimeOfDay?> getTime(BuildContext context) async {
  final now = TimeOfDay.now();

  return await showTimePicker(
    context: context,
    initialTime: now,
    helpText: "Zaman seçin",
    cancelText: "İptal et",
    confirmText: "Kaydet",
    hourLabelText: "Saat",
    minuteLabelText: "Dakika",
    errorInvalidText: "Geçersiz giriş",
  );
}
