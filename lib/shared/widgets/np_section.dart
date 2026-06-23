import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'np_card.dart';

class NpSection extends StatelessWidget {
  const NpSection({
    super.key,
    required this.title,
    required this.child,
    this.description,
  });

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.stackSm),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.stackLg),
        NpCard(
          padding: const EdgeInsets.all(AppSpacing.stackLg),
          child: child,
        ),
      ],
    );
  }
}
