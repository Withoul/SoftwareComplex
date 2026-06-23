import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? icon;
  final Color? color;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.outlineVariant, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTypography.numberSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color ?? AppColors.textPrimary,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 6.0),
                  Text(
                    icon!,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
