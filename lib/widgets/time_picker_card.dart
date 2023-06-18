import 'package:calendar_app/consts/colors.dart';
import 'package:flutter/material.dart';

class TimePickerCard extends StatelessWidget {
  final TimeOfDay? start;
  final TimeOfDay? end;

  final void Function() onTapToStart;
  final void Function() onTapToEnd;

  static const _padding = EdgeInsets.all(16);
  static final _boxDecoration = BoxDecoration(
    color: color2,
    borderRadius: BorderRadius.circular(16),
  );

  const TimePickerCard({
    super.key,
    required this.start,
    required this.end,
    required this.onTapToStart,
    required this.onTapToEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTapToStart,
            child: _getTimeCard(context: context, isStartingAt: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: onTapToEnd,
            child: _getTimeCard(context: context, isStartingAt: false),
          ),
        ),
      ],
    );
  }

  Widget _getTimeCard({
    required BuildContext context,
    required bool isStartingAt,
  }) {
    final String? timeIndicator = getTimeIndicator(
      context,
      isStartingAt ? start : end,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 87),
      child: Container(
        decoration: _boxDecoration,
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isStartingAt ? Icons.history_rounded : Icons.update_rounded,
                  size: 16,
                  color: color1,
                ),
                const SizedBox(width: 8),
                Text(
                  isStartingAt ? "Başlangıç" : "Bitiş",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: color1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              timeIndicator ?? "Dokunarak seçiniz.",
              style: timeIndicator == null
                  ? Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: color1)
                  : Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: color1),
            ),
          ],
        ),
      ),
    );
  }

  String? getTimeIndicator(BuildContext context, TimeOfDay? time) {
    if (time == null) return null;

    return time.format(context);
  }
}
