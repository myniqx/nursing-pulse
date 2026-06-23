import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/diaper_log.dart';
import '../../data/models/weight_entry.dart';
import '../../data/repositories/baby_repository.dart';
import '../../shared/app_theme.dart';
import '../../shared/widgets/np_card.dart';
import '../../shared/widgets/np_stat_tile.dart';

class BabyScreen extends StatefulWidget {
  const BabyScreen({super.key});

  @override
  State<BabyScreen> createState() => _BabyScreenState();
}

class _BabyScreenState extends State<BabyScreen> {
  final _repo = BabyRepository();

  List<DiaperLog> _diapers = [];
  List<WeightEntry> _weights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final diapers = await _repo.getDiapers();
    final weights = await _repo.getWeights();
    setState(() {
      _diapers = diapers;
      _weights = weights;
      _loading = false;
    });
  }

  List<DiaperLog> get _todayDiapers {
    final today = DateTime.now();
    return _diapers
        .where((d) =>
            d.time.year == today.year &&
            d.time.month == today.month &&
            d.time.day == today.day)
        .toList();
  }

  void _showDiaperSheet([DiaperType? preselected]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DiaperInputSheet(
        preselected: preselected,
        onSave: (log) async {
          await _repo.addDiaper(log);
          await _load();
        },
      ),
    );
  }

  Future<void> _deleteDiaper(String id) async {
    await _repo.deleteDiaper(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerPadding,
          AppSpacing.stackMd,
          AppSpacing.containerPadding,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DiaperSection(
              todayCount: _todayDiapers.length,
              diapers: _todayDiapers,
              onAddTap: _showDiaperSheet,
              onDelete: _deleteDiaper,
            ),
            const SizedBox(height: AppSpacing.stackLg),
            _WeightSection(
              weights: _weights,
              onAdd: () => _showWeightSheet(),
              onDelete: (id) async {
                await _repo.deleteWeight(id);
                await _load();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeightInputSheet(
        onSave: (grams) async {
          final entry = WeightEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            date: DateTime.now(),
            grams: grams,
          );
          await _repo.addWeight(entry);
          await _load();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Diaper Section
// ---------------------------------------------------------------------------

class _DiaperSection extends StatelessWidget {
  const _DiaperSection({
    required this.todayCount,
    required this.diapers,
    required this.onAddTap,
    required this.onDelete,
  });

  final int todayCount;
  final List<DiaperLog> diapers;
  final void Function([DiaperType?]) onAddTap;
  final void Function(String) onDelete;

  String _typeLabel(DiaperType t) => switch (t) {
        DiaperType.wet => 'Wet',
        DiaperType.dirty => 'Dirty',
        DiaperType.both => 'Both',
      };

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Diapers',
                style: Theme.of(context).textTheme.headlineMedium),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '$todayCount today',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.tertiary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackMd),
        // Quick-tap buttons — open sheet with type pre-selected
        Row(
          children: [
            Expanded(
              child: _DiaperButton(
                label: 'Wet',
                icon: Icons.water_drop_outlined,
                color: AppColors.primary,
                onTap: () => onAddTap(DiaperType.wet),
              ),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Expanded(
              child: _DiaperButton(
                label: 'Dirty',
                icon: Icons.circle_outlined,
                color: AppColors.tertiary,
                onTap: () => onAddTap(DiaperType.dirty),
              ),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Expanded(
              child: _DiaperButton(
                label: 'Both',
                icon: Icons.multiple_stop,
                color: AppColors.secondary,
                onTap: () => onAddTap(DiaperType.both),
              ),
            ),
          ],
        ),
        if (diapers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.stackMd),
          NpCard(
            child: Column(
              children: diapers.take(5).toList().asMap().entries.map((entry) {
                final i = entry.key;
                final d = entry.value;
                final visibleCount = diapers.length > 5 ? 5 : diapers.length;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.child_care,
                                size: 18, color: AppColors.tertiary),
                          ),
                          const SizedBox(width: AppSpacing.stackMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_typeLabel(d.type),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge),
                                Text(
                                  _relativeTime(d.time),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.onSurfaceVariant),
                            onPressed: () => onDelete(d.id),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < visibleCount - 1)
                      const Divider(
                          color: AppColors.surfaceContainerHigh, height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
          if (diapers.length > 5) ...[
            const SizedBox(height: AppSpacing.stackSm),
            Center(
              child: Text(
                '+${diapers.length - 5} more today — full history in Stats',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _DiaperButton extends StatelessWidget {
  const _DiaperButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NpCard(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.stackMd, horizontal: AppSpacing.stackSm),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: AppSpacing.stackSm),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Diaper Input Sheet
// ---------------------------------------------------------------------------

class _DiaperInputSheet extends StatefulWidget {
  const _DiaperInputSheet({
    required this.onSave,
    this.preselected,
  });

  final void Function(DiaperLog) onSave;
  final DiaperType? preselected;

  @override
  State<_DiaperInputSheet> createState() => _DiaperInputSheetState();
}

class _DiaperInputSheetState extends State<_DiaperInputSheet> {
  late DiaperType _selectedType;
  late DateTime _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preselected ?? DiaperType.wet;
    _selectedTime = DateTime.now();
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours}h ago';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNow = DateTime.now().difference(_selectedTime).inMinutes < 1;
    final timeDisplay = isNow
        ? 'Now'
        : _relativeTime(_selectedTime);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.gutter),
      padding: EdgeInsets.only(
        left: AppSpacing.stackLg,
        right: AppSpacing.stackLg,
        top: AppSpacing.stackLg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.stackLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log Diaper',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.stackLg),
          Text('Type',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  )),
          const SizedBox(height: AppSpacing.stackMd),
          Row(
            children: DiaperType.values.map((type) {
              final selected = _selectedType == type;
              final label = switch (type) {
                DiaperType.wet => 'Wet',
                DiaperType.dirty => 'Dirty',
                DiaperType.both => 'Both',
              };
              final color = switch (type) {
                DiaperType.wet => AppColors.primary,
                DiaperType.dirty => AppColors.tertiary,
                DiaperType.both => AppColors.secondary,
              };
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: type != DiaperType.both ? AppSpacing.stackMd : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: selected ? color : AppColors.outlineVariant,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                                color:
                                    selected ? color : AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Text('Time',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  )),
          const SizedBox(height: AppSpacing.stackMd),
          GestureDetector(
            onTap: _pickTime,
            child: NpCard(
              borderColor: AppColors.primary,
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.stackMd),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeDisplay,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      if (!isNow)
                        Text(
                          TimeOfDay.fromDateTime(_selectedTime).format(context),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Change',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onSave(DiaperLog(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  time: _selectedTime,
                  type: _selectedType,
                ));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weight Section
// ---------------------------------------------------------------------------

class _WeightSection extends StatelessWidget {
  const _WeightSection({
    required this.weights,
    required this.onAdd,
    required this.onDelete,
  });

  final List<WeightEntry> weights;
  final VoidCallback onAdd;
  final void Function(String) onDelete;

  String _dateLabel(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Weight',
                style: Theme.of(context).textTheme.headlineMedium),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 16, color: AppColors.onPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'Log weight',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackMd),
        if (weights.isEmpty)
          NpCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.stackLg),
                child: Text(
                  'No weight entries yet.\nTap "Log weight" to add the first one.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          )
        else ...[
          NpStatTile(
            icon: Icons.monitor_weight_outlined,
            label: 'Latest weight',
            value: (weights.first.grams / 1000).toStringAsFixed(2),
            unit: 'kg',
            iconColor: AppColors.primary,
          ),
          if (weights.length >= 2) ...[
            const SizedBox(height: AppSpacing.stackMd),
            Builder(builder: (context) {
              final diff = weights.first.grams - weights[1].grams;
              final sign = diff >= 0 ? '+' : '';
              return NpCard(
                color: diff >= 0
                    ? AppColors.primaryFixed.withValues(alpha: 0.30)
                    : AppColors.errorContainer.withValues(alpha: 0.30),
                child: Row(
                  children: [
                    Icon(
                      diff >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: diff >= 0 ? AppColors.primary : AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.stackMd),
                    Text(
                      '$sign${diff}g since last entry',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: diff >= 0
                                ? AppColors.primary
                                : AppColors.error,
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: AppSpacing.stackMd),
          NpCard(
            child: Column(
              children: weights.take(5).toList().asMap().entries.map((entry) {
                final i = entry.key;
                final w = entry.value;
                final visibleCount = weights.length > 5 ? 5 : weights.length;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.monitor_weight_outlined,
                                size: 18, color: AppColors.primary),
                          ),
                          const SizedBox(width: AppSpacing.stackMd),
                          Expanded(
                            child: Text(
                              _dateLabel(w.date),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          Text(
                            '${(w.grams / 1000).toStringAsFixed(2)} kg',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(width: AppSpacing.stackMd),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.onSurfaceVariant),
                            onPressed: () => onDelete(w.id),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < visibleCount - 1)
                      const Divider(
                          color: AppColors.surfaceContainerHigh, height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
          if (weights.length > 5) ...[
            const SizedBox(height: AppSpacing.stackSm),
            Center(
              child: Text(
                '+${weights.length - 5} more — full history in Stats',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Weight Input Sheet
// ---------------------------------------------------------------------------

class _WeightInputSheet extends StatefulWidget {
  const _WeightInputSheet({required this.onSave});
  final void Function(int grams) onSave;

  @override
  State<_WeightInputSheet> createState() => _WeightInputSheetState();
}

class _WeightInputSheetState extends State<_WeightInputSheet> {
  final _controller = TextEditingController();
  bool _isKg = true;

  int? get _grams {
    final val = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (val == null) return null;
    return _isKg ? (val * 1000).round() : val.round();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.gutter),
      padding: EdgeInsets.only(
        left: AppSpacing.stackLg,
        right: AppSpacing.stackLg,
        top: AppSpacing.stackLg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.stackLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log Weight',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.stackLg),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: _isKg ? '3.50' : '3500',
                    filled: true,
                    fillColor: AppColors.primaryFixed.withValues(alpha: 0.20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: AppSpacing.stackMd),
              GestureDetector(
                onTap: () => setState(() => _isKg = !_isKg),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    _isKg ? 'kg' : 'g',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackLg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full)),
                disabledBackgroundColor: AppColors.surfaceContainerHigh,
              ),
              onPressed: _grams != null
                  ? () {
                      widget.onSave(_grams!);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
