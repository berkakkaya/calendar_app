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
    final Widget titleText = Text(
      isStartingAt ? "Başlangıç Tarihi" : "Bitiş Tarihi",
      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: color1),
    );

    final Widget dateText = Text(
      time == null
          ? "Bir zaman seçmek için dokunun."
          : getDateFormatter(dateAndTime).format(time!),
      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: color1),
    );

    return Container(
      decoration: BoxDecoration(
        color: color2,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.schedule_rounded, size: 24, color: color1),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleText,
                const SizedBox(height: 8),
                dateText,
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.arrow_forward_rounded, size: 24, color: color1),
        ],
      ),
    );
  }
}
