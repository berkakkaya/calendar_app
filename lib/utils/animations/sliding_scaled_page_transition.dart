import 'package:flutter/material.dart';

class SlidingScaledPageTransition {
  static final barrierColor = Colors.black.withAlpha(75);
  static const duration = Duration(milliseconds: 600);

  static Widget generate(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondAnimation,
    Widget child,
  ) {
    const scaleStart = 0.0;
    const scaleEnd = 1.0;
    const offsetBegin = Offset(0, 0.9);
    const offsetEnd = Offset.zero;

    const curveSlide = Curves.easeInOutQuad;
    const curveScale = Curves.decelerate;

    final scaleTween = Tween(begin: scaleStart, end: scaleEnd).chain(
      CurveTween(curve: curveScale),
    );
    final slideTween = Tween(begin: offsetBegin, end: offsetEnd)
        .chain(CurveTween(curve: curveSlide));

    return SlideTransition(
      position: animation.drive(slideTween),
      child: ScaleTransition(
        scale: animation.drive(scaleTween),
        child: child,
      ),
    );
  }
}
