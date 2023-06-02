import 'package:calendar_app/consts/colors.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/utils/formatter.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final EventShortForm event;
  final bool happeningNow;

  const EventCard({
    super.key,
    required this.event,
    this.happeningNow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: Complete this later
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: happeningNow ? color6 : color3,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TimeIndicator(
              startingDate: event.startsAt!,
              endingDate: event.endsAt!,
            ),
            const SizedBox(height: 8),
            Text(
              event.name!,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: color1),
            ),
            const SizedBox(height: 8),
            Text(
              event.type!,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: color1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeIndicator extends StatelessWidget {
  final DateTime startingDate;
  final DateTime endingDate;

  const _TimeIndicator({
    required this.startingDate,
    required this.endingDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          getDateFormatter(hourMinuteFormat).format(startingDate),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: color1,
              ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, size: 24, color: color1),
        const SizedBox(width: 8),
        Text(
          getDateFormatter(hourMinuteFormat).format(endingDate),
          style:
              Theme.of(context).textTheme.titleLarge!.copyWith(color: color1),
        ),
      ],
    );
  }
}
