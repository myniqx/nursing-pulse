import '../../shared/dev_utils.dart';
import 'package:flutter/material.dart';
import 'package:nursing_pulse/l10n/app_localizations.dart';
import 'package:nursing_pulse/main.dart';
import 'package:nursing_pulse/services/nursing_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/dev/mock_data_seeder.dart';
import '../../data/models/baby_profile.dart';
import '../../data/repositories/baby_repository.dart';
import '../../shared/app_theme.dart';
import '../../shared/widgets/np_section.dart';
import '../../shared/widgets/nursing_badge.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repo = BabyRepository();
  bool _clearing = false;
  bool _seeding = false;
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  double? _customInterval;
  bool _loading = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _repo.getProfile();
    if (profile != null) {
      _nameController.text = profile.name;
      setState(() {
        _birthDate = profile.birthDate;
        _customInterval = profile.customFeedIntervalHours;
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _birthDate == null) return;
    await _repo.saveProfile(BabyProfile(
      name: _nameController.text.trim(),
      birthDate: _birthDate!,
      customFeedIntervalHours: _customInterval,
    ));
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  String _ageLabel(BuildContext context, DateTime birth) {
    final l10n = AppLocalizations.of(context);
    final weeks = DateTime.now().difference(birth).inDays ~/ 7;
    if (weeks < 4) return l10n.weeksOld(weeks);
    final months = DateTime.now().difference(birth).inDays ~/ 30;
    return l10n.monthsOld(months);
  }

  static const double _sliderMin = 1.0;
  static const double _sliderMax = 6.0;
  static const int _sliderDivisions = 10;

  String _intervalLabel(double h) {
    final hInt = h.truncate();
    final half = (h - hInt) >= 0.5;
    if (half) return '${hInt}h 30m';
    return '${hInt}h';
  }

  Future<void> _clearStats() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsClearStatsConfirmTitle),
        content: Text(l10n.settingsClearStatsConfirmHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.settingsClearStatsCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.settingsClearStatsConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _clearing = true);
    await _deleteAllStats();
    if (mounted) {
      setState(() => _clearing = false);
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('np_sessions');
    await prefs.remove('np_active_session');
    await prefs.remove('np_diapers');
    await prefs.remove('np_weights');
    await prefs.remove('np_mock_seeded_v');
  }

  Future<void> _seedData() async {
    setState(() => _seeding = true);
    await _deleteAllStats();
    await MockDataSeeder.forceSeed();
    if (mounted) {
      setState(() => _seeding = false);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final recommended = _birthDate != null
        ? BabyProfile(name: '', birthDate: _birthDate!).recommendedIntervalHours
        : null;

    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.stackMd,
        AppSpacing.containerPadding,
        80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1 — Baby Profile
          NpSection(
            title: l10n.settingsBabyProfile,
            description: l10n.settingsBabyProfileHint,
            child: _BabyProfileForm(
              nameController: _nameController,
              birthDate: _birthDate,
              customInterval: _customInterval,
              recommended: recommended,
              saved: _saved,
              sliderMin: _sliderMin,
              sliderMax: _sliderMax,
              sliderDivisions: _sliderDivisions,
              onPickDate: _pickDate,
              onIntervalChanged: (v) => setState(() => _customInterval = v),
              onResetInterval: () => setState(() => _customInterval = null),
              onSave: _save,
              formatDate: _formatDate,
              ageLabel: (dt) => _ageLabel(context, dt),
              intervalLabel: _intervalLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),

          // 2 — Notifications
          _NotificationsSection(l10n: l10n),
          const SizedBox(height: AppSpacing.stackLg),

          // 3 — Language
          _LanguageSection(l10n: l10n),
          const SizedBox(height: AppSpacing.stackLg),

          // 4 — Data
          NpSection(
            title: l10n.settingsClearStats,
            description: l10n.settingsClearStatsHint,
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full)),
                ),
                onPressed: _clearing ? null : _clearStats,
                icon: _clearing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.error),
                      )
                    : const Icon(Icons.delete_outline),
                label: Text(l10n.settingsClearStats),
              ),
            ),
          ),

          // 5 — Dev (debug only)
          if (isDev) ...[
            const SizedBox(height: AppSpacing.stackLg),
            _DevSection(
              seeding: _seeding,
              onSeed: _seedData,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Baby Profile Form
// ---------------------------------------------------------------------------

class _BabyProfileForm extends StatelessWidget {
  const _BabyProfileForm({
    required this.nameController,
    required this.birthDate,
    required this.customInterval,
    required this.recommended,
    required this.saved,
    required this.sliderMin,
    required this.sliderMax,
    required this.sliderDivisions,
    required this.onPickDate,
    required this.onIntervalChanged,
    required this.onResetInterval,
    required this.onSave,
    required this.formatDate,
    required this.ageLabel,
    required this.intervalLabel,
  });

  final TextEditingController nameController;
  final DateTime? birthDate;
  final double? customInterval;
  final (double, double)? recommended;
  final bool saved;
  final double sliderMin;
  final double sliderMax;
  final int sliderDivisions;
  final VoidCallback onPickDate;
  final ValueChanged<double> onIntervalChanged;
  final VoidCallback onResetInterval;
  final VoidCallback onSave;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) ageLabel;
  final String Function(double) intervalLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(l10n.settingsBabyName,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.stackSm),
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.settingsBabyNameHint,
            filled: true,
            fillColor: AppColors.primaryFixed.withValues(alpha: 0.20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackLg),

        // Birth date
        Text(l10n.settingsBirthDate,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.stackSm),
        GestureDetector(
          onTap: onPickDate,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.stackMd),
                Text(
                  birthDate != null
                      ? formatDate(birthDate!)
                      : l10n.settingsBirthDateSelect,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: birthDate != null
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (birthDate != null) ...[
          const SizedBox(height: AppSpacing.stackMd),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              ageLabel(birthDate!),
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.stackLg),
        const Divider(color: AppColors.outlineVariant),
        const SizedBox(height: AppSpacing.stackLg),

        // Feed interval
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.settingsFeedIntervalLabel,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.onSurfaceVariant)),
            if (customInterval != null)
              GestureDetector(
                onTap: onResetInterval,
                child: Text(
                  l10n.settingsResetToRecommended,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackSm),
        if (recommended != null) ...[
          Text(
            customInterval == null
                ? l10n.settingsRecommendedForAge(
                    recommended!.$1, recommended!.$2)
                : l10n.settingsCustomInterval(
                    intervalLabel(customInterval!)),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: customInterval == null
                      ? AppColors.onSurfaceVariant
                      : AppColors.primary,
                ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor:
                  AppColors.primary.withValues(alpha: 0.15),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle:
                  const TextStyle(color: AppColors.onPrimary),
            ),
            child: Slider(
              value:
                  customInterval ?? (recommended!.$1 + recommended!.$2) / 2,
              min: sliderMin,
              max: sliderMax,
              divisions: sliderDivisions,
              label: intervalLabel(
                  customInterval ?? (recommended!.$1 + recommended!.$2) / 2),
              onChanged: onIntervalChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.settingsFeedIntervalMin,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.onSurfaceVariant)),
              Text(l10n.settingsFeedIntervalMax,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Text(
            l10n.settingsFeedIntervalDisclaimer,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
          ),
        ] else ...[
          Text(
            l10n.settingsEnterBirthDate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
        const SizedBox(height: AppSpacing.stackLg),

        // Save
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor:
                  saved ? AppColors.primaryContainer : AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full)),
            ),
            onPressed: onSave,
            icon: Icon(
              saved ? Icons.check : Icons.save_outlined,
              color: saved
                  ? AppColors.onPrimaryContainer
                  : AppColors.onPrimary,
            ),
            label: Text(
              saved ? l10n.settingsSaved : l10n.settingsSaveProfile,
              style: TextStyle(
                color: saved
                    ? AppColors.onPrimaryContainer
                    : AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications Section
// ---------------------------------------------------------------------------

class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection({required this.l10n});
  final AppLocalizations l10n;

  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool _notif = true;
  bool _overlay = true;
  final _svc = NursingSessionService.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await _svc.isNotifEnabled;
    final o = await _svc.isOverlayEnabled;
    setState(() {
      _notif = n;
      _overlay = o;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return NpSection(
      title: l10n.settingsNotifications,
      description: l10n.settingsNotificationsHint,
      child: Column(
        children: [
          _ToggleTile(
            icon: Icons.notifications_outlined,
            title: l10n.settingsNotifTimer,
            subtitle: l10n.settingsNotifTimerHint,
            value: _notif,
            onChanged: (v) async {
              await _svc.setNotifEnabled(v);
              setState(() => _notif = v);
            },
          ),
          const Divider(color: AppColors.surfaceContainerHigh, height: 1),
          _ToggleTile(
            icon: Icons.picture_in_picture_alt_outlined,
            title: l10n.settingsOverlay,
            subtitle: l10n.settingsOverlayHint,
            value: _overlay,
            onChanged: (v) async {
              await _svc.setOverlayEnabled(v);
              setState(() => _overlay = v);
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: value ? AppColors.primary : AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        )),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryFixed,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language Section
// ---------------------------------------------------------------------------

class _LanguageSection extends StatelessWidget {
  const _LanguageSection({required this.l10n});

  final AppLocalizations l10n;

  static const _languages = [
    (code: 'en', label: 'English'),
    (code: 'tr', label: 'Türkçe'),
    (code: 'nl', label: 'Nederlands'),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = NursingPulseApp.of(context);
    final currentCode = Localizations.localeOf(context).languageCode;

    return NpSection(
      title: l10n.settingsLanguage,
      description: l10n.settingsLanguageHint,
      child: Column(
        children: [
          _LanguageTile(
            label: l10n.settingsLanguageSystem,
            selected: false,
            isSystem: true,
            onTap: () => appState.setLocale(null),
          ),
          const Divider(color: AppColors.surfaceContainerHigh, height: 1),
          ..._languages.asMap().entries.map((entry) {
            final i = entry.key;
            final lang = entry.value;
            return Column(
              children: [
                _LanguageTile(
                  label: lang.label,
                  selected: currentCode == lang.code,
                  onTap: () => appState.setLocale(Locale(lang.code)),
                ),
                if (i < _languages.length - 1)
                  const Divider(
                      color: AppColors.surfaceContainerHigh, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isSystem = false,
  });

  final String label;
  final bool selected;
  final bool isSystem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              isSystem ? Icons.language : Icons.translate,
              size: 20,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          selected ? AppColors.primary : AppColors.onSurface,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dev Section (debug only)
// ---------------------------------------------------------------------------

class _DevSection extends StatelessWidget {
  const _DevSection({required this.seeding, required this.onSeed});

  final bool seeding;
  final VoidCallback onSeed;

  @override
  Widget build(BuildContext context) {
    return NpSection(
      title: '[DEV]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seed button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full)),
              ),
              onPressed: seeding ? null : onSeed,
              icon: seeding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.secondary),
                    )
                  : const Icon(Icons.science_outlined),
              label: const Text('Seed 6 Months of Data'),
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          const Divider(color: AppColors.outlineVariant),
          const SizedBox(height: AppSpacing.stackLg),

          // Overlay badge preview
          Text(
            'Floating badge preview',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          NursingBadge(
            formattedTime: '04:32',
            onFinish: () {},
          ),
          const SizedBox(height: AppSpacing.stackLg),

        ],
      ),
    );
  }
}
