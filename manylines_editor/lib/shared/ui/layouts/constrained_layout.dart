import 'package:flutter/material.dart';

class ConstrainedLayout extends StatelessWidget {
  final Widget child;
  final double maxWidthRatio;
  final double maxHeightRatio;

  const ConstrainedLayout({
    super.key,
    required this.child,
    this.maxWidthRatio = 0.7,
    this.maxHeightRatio = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * maxWidthRatio,
          maxHeight: MediaQuery.of(context).size.height * maxHeightRatio,
        ),
        child: child,
      ),
    );
  }
}