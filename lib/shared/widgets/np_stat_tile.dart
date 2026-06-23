import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'np_card.dart';

class NpStatTile extends StatelessWidget {
  const NpStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.iconColor = AppColors.primary,
    this.color = AppColors.surfaceContainerLowest,
    this.borderColor = AppColors.cardBorder,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color iconColor;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return NpCard(
      color: color,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: AppSpacing.stackSm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.stackSm),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextSpan(
                  text: '  $unit',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
