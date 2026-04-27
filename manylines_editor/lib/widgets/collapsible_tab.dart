import 'package:flutter/material.dart';

class CollapsibleTab extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double height;
  final double offset;

  const CollapsibleTab({
    super.key,
    required this.onTap,
    required this.icon,
    this.height = 48,
    this.offset = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          SizedBox(height: offset),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 24,
              height: height,
              decoration: BoxDecoration(
                color: Colors.blue[700],
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}