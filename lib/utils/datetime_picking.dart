import 'package:flutter/material.dart';

Future<DateTime?> pickDateAndTime(BuildContext context) async {
  DateTime nowDate = DateTime.now();
  TimeOfDay nowTime = TimeOfDay.now();

  DateTime? date;
  TimeOfDay? time;

  date = await showDatePicker(
    context: context,
    initialDate: nowDate,
    firstDate: nowDate,
    lastDate: nowDate.add(const Duration(days: 365 * 5)),
    helpText: "Tarih seçin",
    cancelText: "İptal et",
    confirmText: "Kaydet",
    errorFormatText: "Geçersiz tarih formatı",
    errorInvalidText: "Geçersiz tarih girişi",
    fieldLabelText: "Tarih",
  );

  if (date == null) return null;

  if (context.mounted) {
    time = await showTimePicker(
      context: context,
      initialTime: nowTime,
      helpText: "Zaman seçin",
      cancelText: "İptal et",
      confirmText: "Kaydet",
      hourLabelText: "Saat",
      minuteLabelText: "Dakika",
      errorInvalidText: "Geçersiz giriş",
    );
  }

  if (time == null) return null;

  date = date.copyWith(hour: time.hour, minute: time.minute);
  return date;
}
