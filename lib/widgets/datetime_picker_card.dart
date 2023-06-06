import 'package:calendar_app/consts/colors.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/utils/formatter.dart';
import 'package:flutter/material.dart';

class DatePickerCard extends StatelessWidget {
  final bool isStartingAt;
  final DateTime? time;
  final void Function()? onTap;

  const DatePickerCard({
    super.key,
    required this.isStartingAt,
    this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.schedule_rounded, size: 24),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isStartingAt ? "Başlangıç Tarihi" : "Bitiş Tarihi",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  time == null
                      ? ""
                      : getDateFormatter(dateAndTime).format(time!),
                  style: Theme.of(context).textTheme.labelMedium,
                )
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 24),
          ],
        ),
      ),
    );
  }
}
