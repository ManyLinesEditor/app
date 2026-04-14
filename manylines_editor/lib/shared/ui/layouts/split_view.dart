import 'package:flutter/material.dart';

class SplitView extends StatelessWidget {
  final List<Widget> children;
  final List<double>? weights;
  final Color? dividerColor;
  final double dividerThickness;

  const SplitView({
    super.key,
    required this.children,
    this.weights,
    this.dividerColor,
    this.dividerThickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (children.length <= 1) {
      return children.isNotEmpty ? children.first : const SizedBox();
    }

    final effectiveWeights = weights ?? List.filled(children.length, 1.0);
    final totalWeight = effectiveWeights.reduce((a, b) => a + b);

    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(
            flex: effectiveWeights[i].round(),
            child: children[i],
          ),
          if (i < children.length - 1)
            Container(
              width: dividerThickness,
              color: dividerColor ?? Colors.grey[300],
            ),
        ],
      ],
    );
  }
}