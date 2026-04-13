import 'package:flutter/material.dart';

class SwipeDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final double threshold;

  const SwipeDetector({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.threshold = 300,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond.dx;
        if (velocity < -threshold && onSwipeLeft != null) {
          onSwipeLeft!();
        } else if (velocity > threshold && onSwipeRight != null) {
          onSwipeRight!();
        }
      },
      child: child,
    );
  }
}