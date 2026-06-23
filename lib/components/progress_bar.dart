import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color color;

  const ProgressBar({
    Key? key,
    required this.progress,
    this.height = 8.0,
    this.color = AppColors.secondary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double widthFactor = min(max(progress, 0.0), 1.0);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: constraints.maxWidth * widthFactor,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
