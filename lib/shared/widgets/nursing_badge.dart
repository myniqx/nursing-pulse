import 'package:flutter/material.dart';
import '../app_theme.dart';

class NursingBadge extends StatelessWidget {
  const NursingBadge({
    super.key,
    required this.formattedTime,
    required this.onFinish,
    this.onOpenApp,
  });

  final String formattedTime;
  final VoidCallback onFinish;
  final VoidCallback? onOpenApp;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onOpenApp,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  formattedTime,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                    height: 1,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: onFinish,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.onTertiary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
