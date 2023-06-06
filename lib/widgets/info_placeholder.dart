import 'package:flutter/material.dart';

class InfoPlaceholder extends StatelessWidget {
  final Widget icon;
  final String title;
  final Widget? content;

  const InfoPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: icon,
        ),
        const SizedBox(width: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 8),
            content == null ? const SizedBox() : content!,
          ],
        ),
      ],
    );
  }
}
