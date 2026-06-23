import 'package:flutter/material.dart';
import '../app_theme.dart';

class NpTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NpTopAppBar({super.key, this.onSettingsTap});

  final VoidCallback? onSettingsTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: AppSpacing.containerPadding,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.secondaryContainer,
            child: const Icon(Icons.person, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Text(
            'Nursing Pulse',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: AppSpacing.stackSm),
      ],
    );
  }
}
