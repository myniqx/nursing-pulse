import 'package:flutter/material.dart';
import 'package:nursing_pulse/l10n/app_localizations.dart';
import '../app_theme.dart';

class NpTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NpTopAppBar({super.key, this.onSettingsTap, this.onIconTap});

  final VoidCallback? onSettingsTap;
  final VoidCallback? onIconTap;

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
          GestureDetector(
            onTap: onIconTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.secondaryContainer,
              backgroundImage: const AssetImage('assets/icon.png'),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context).appTitle,
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
