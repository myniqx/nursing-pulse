import 'package:flutter/material.dart';
import '../app_theme.dart';

class NpCard extends StatelessWidget {
  const NpCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.stackMd),
    this.color = AppColors.surfaceContainerLowest,
    this.borderColor = AppColors.cardBorder,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: child,
    );
  }
}
