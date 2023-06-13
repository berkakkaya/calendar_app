import 'package:calendar_app/consts/colors.dart';
import 'package:flutter/material.dart';

class ParticipantsCard extends StatelessWidget {
  final int participantCount;

  const ParticipantsCard({
    super.key,
    required this.participantCount,
  });

  @override
  Widget build(BuildContext context) {
    assert(participantCount >= 0, "Participant count cannot be lower than 0.");

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color2,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.groups_outlined, size: 24, color: color1),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Katılımcıları Düzenle",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: color1),
                ),
                const SizedBox(height: 8),
                Text(
                  participantCount == 0
                      ? "Hiç katılımcı seçilmedi"
                      : "$participantCount katılımcı seçildi",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: color1),
                ),
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
