import 'package:calendar_app/consts/colors.dart';
import 'package:flutter/material.dart';

class ProgressCounter extends StatelessWidget {
  final int totalCount;
  final int current;

  const ProgressCounter({
    super.key,
    required this.totalCount,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> dots = [];
    bool makeItFilled;

    for (int i = 0; i < totalCount; i++) {
      makeItFilled = i < current;

      dots.add(
        Expanded(
          flex: 10,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: makeItFilled ? color3 : color4,
            ),
          ),
        ),
      );

      if (i != totalCount - 1) {
        dots.add(const Spacer());
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: dots,
      ),
    );
  }
}
