import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/dev/mock_data_seeder.dart';
import '../../data/models/baby_profile.dart';
import '../../data/repositories/baby_repository.dart';
import '../../shared/app_theme.dart';
import '../../shared/widgets/np_card.dart';

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
  double? _customInterval; // null = use recommended
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

  String _ageLabel(DateTime birth) {
    final weeks = DateTime.now().difference(birth).inDays ~/ 7;
    if (weeks < 4) return '$weeks weeks old';
    final months = DateTime.now().difference(birth).inDays ~/ 30;
    return '$months months old';
  }

  // Slider goes 1.0–6.0 h in 0.5 steps
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all stats?'),
        content: const Text(
            'This will permanently delete all nursing sessions, diapers and weight entries. Baby profile will be kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
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
        ? BabyProfile(name: '', birthDate: _birthDate!)
            .recommendedIntervalHours
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.stackMd,
        AppSpacing.containerPadding,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Baby Profile',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.stackSm),
          Text(
            'Used to calculate recommended feed intervals',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          NpCard(
            padding: const EdgeInsets.all(AppSpacing.stackLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text("Baby's name",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        )),
                const SizedBox(height: AppSpacing.stackSm),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'e.g. Emma',
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
                Text('Date of birth',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        )),
                const SizedBox(height: AppSpacing.stackSm),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
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
                          _birthDate != null
                              ? _formatDate(_birthDate!)
                              : 'Select date',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _birthDate != null
                                        ? AppColors.onSurface
                                        : AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_birthDate != null) ...[
                  const SizedBox(height: AppSpacing.stackMd),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      _ageLabel(_birthDate!),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                          ),
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
                    Text('Feed interval',
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                )),
                    if (_customInterval != null)
                      GestureDetector(
                        onTap: () => setState(() => _customInterval = null),
                        child: Text(
                          'Reset to recommended',
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
                    _customInterval == null
                        ? 'Recommended for age: every ${recommended.$1}–${recommended.$2}h'
                        : 'Custom: every ${_intervalLabel(_customInterval!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _customInterval == null
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
                      overlayColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      valueIndicatorColor: AppColors.primary,
                      valueIndicatorTextStyle: const TextStyle(
                          color: AppColors.onPrimary),
                    ),
                    child: Slider(
                      value: _customInterval ??
                          (recommended.$1 + recommended.$2) / 2,
                      min: _sliderMin,
                      max: _sliderMax,
                      divisions: _sliderDivisions,
                      label: _intervalLabel(_customInterval ??
                          (recommended.$1 + recommended.$2) / 2),
                      onChanged: (v) =>
                          setState(() => _customInterval = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1h',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: AppColors.onSurfaceVariant)),
                      Text('6h',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Enter birth date to see recommendation',
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
                      backgroundColor: _saved
                          ? AppColors.primaryContainer
                          : AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.full)),
                    ),
                    onPressed: _save,
                    icon: Icon(
                      _saved ? Icons.check : Icons.save_outlined,
                      color: _saved
                          ? AppColors.onPrimaryContainer
                          : AppColors.onPrimary,
                    ),
                    label: Text(
                      _saved ? 'Saved!' : 'Save Profile',
                      style: TextStyle(
                        color: _saved
                            ? AppColors.onPrimaryContainer
                            : AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          // Clear stats
          SizedBox(
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
              label: const Text('Clear All Stats'),
            ),
          ),
          // Seed button — dev only
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.stackMd),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(
                      color: AppColors.secondary, style: BorderStyle.solid),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full)),
                ),
                onPressed: _seeding ? null : _seedData,
                icon: _seeding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.secondary),
                      )
                    : const Icon(Icons.science_outlined),
                label: const Text('[DEV] Seed 6 Months of Data'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
