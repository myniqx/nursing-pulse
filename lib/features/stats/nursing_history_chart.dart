import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/diaper_log.dart';
import '../../data/models/session.dart';
import '../../data/models/weight_entry.dart';
import '../../shared/app_theme.dart';
import '../../shared/widgets/np_card.dart';

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class NursingHistoryChart extends StatefulWidget {
  const NursingHistoryChart({
    super.key,
    required this.sessions,
    required this.diapers,
    required this.weights,
  });

  final List<Session> sessions;
  final List<DiaperLog> diapers;
  final List<WeightEntry> weights;

  @override
  State<NursingHistoryChart> createState() => _NursingHistoryChartState();
}

class _NursingHistoryChartState extends State<NursingHistoryChart> {
  late DateTimeRange _range;
  int? _selectedBarIndex;

  // Cached computations — only rebuilt when range or widget data changes
  late List<_BarData> _cachedBars;
  late int _cachedMaxMin;

  @override
  void initState() {
    super.initState();
    final today = _d(DateTime.now());
    _range = DateTimeRange(start: today, end: today);
    _rebuildCache();
  }

  @override
  void didUpdateWidget(NursingHistoryChart old) {
    super.didUpdateWidget(old);
    if (old.sessions != widget.sessions ||
        old.diapers != widget.diapers ||
        old.weights != widget.weights) {
      _rebuildCache();
    }
  }

  void _rebuildCache() {
    _cachedBars = _bars;
    _cachedMaxMin = _cachedBars.fold(0, (m, b) => math.max(m, b.minutes));
    _rebuildStats();
  }

  late _PeriodStats _cachedStats;

  void _rebuildStats() {
    if (_selectedBarIndex != null && _selectedBarIndex! < _cachedBars.length) {
      final bar = _cachedBars[_selectedBarIndex!];
      _cachedStats = _statsFor(DateTimeRange(start: bar.periodStart, end: bar.periodEnd));
    } else {
      _cachedStats = _statsFor(_range);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  DateTime _d(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  int get _rangeDays => _range.end.difference(_range.start).inDays + 1;

  List<Session> get _filteredSessions => widget.sessions.where((s) {
        final d = _d(s.startTime);
        return !d.isBefore(_range.start) && !d.isAfter(_range.end);
      }).toList();

  // --- Bar data ---

  List<_BarData> get _bars {
    if (_rangeDays == 1) return _singleDayBars;
    if (_rangeDays <= 31) return _multiDayBars;
    return _monthBars;
  }

  List<_BarData> get _singleDayBars {
    final slots = List.generate(8, (i) => _BarData(
          label: _hourLabel(i * 3),
          minutes: 0,
          isNight: i * 3 < 6,
          periodStart: _range.start.add(Duration(hours: i * 3)),
          periodEnd: _range.start.add(Duration(hours: i * 3 + 3)),
        ));
    for (final s in _filteredSessions) {
      final slot = s.startTime.hour ~/ 3;
      slots[slot] = slots[slot].add(s.duration.inMinutes);
    }
    return slots;
  }

  List<_BarData> get _multiDayBars {
    return List.generate(_rangeDays, (i) {
      final day = _range.start.add(Duration(days: i));
      final mins = _filteredSessions
          .where((s) => _d(s.startTime) == day)
          .fold(0, (sum, s) => sum + s.duration.inMinutes);
      return _BarData(
        label: _dayLabel(day),
        minutes: mins,
        isNight: false,
        periodStart: day,
        periodEnd: day,
      );
    });
  }

  List<_BarData> get _monthBars {
    final months = <DateTime>{};
    for (var i = 0; i < _rangeDays; i++) {
      final d = _range.start.add(Duration(days: i));
      months.add(DateTime(d.year, d.month));
    }
    final sorted = months.toList()..sort((a, b) => a.compareTo(b));
    return sorted.map((m) {
      final mins = _filteredSessions
          .where((s) => s.startTime.year == m.year && s.startTime.month == m.month)
          .fold(0, (sum, s) => sum + s.duration.inMinutes);
      final lastDay = DateTime(m.year, m.month + 1, 0);
      return _BarData(
        label: _monthLabel(m),
        minutes: mins,
        isNight: false,
        periodStart: m,
        periodEnd: lastDay,
      );
    }).toList();
  }

  // --- Label helpers ---

  String _hourLabel(int h) {
    if (h == 0) return '12a';
    if (h < 12) return '${h}a';
    if (h == 12) return '12p';
    return '${h - 12}p';
  }

  String _dayLabel(DateTime d) => '${d.day}/${d.month}';

  String _monthLabel(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[d.month - 1];
  }

  // Label step: show every Nth label so they don't overlap
  int _labelStep(int count) {
    if (count <= 14) return 1;
    if (count <= 28) return (count / 4).ceil();
    return (count / 4).ceil();
  }

  String get _rangeTitle {
    final today = _d(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    if (_range.start == today && _range.end == today) return 'Today';
    if (_range.start == yesterday && _range.end == yesterday) return 'Yesterday';
    if (_rangeDays == 7) return 'Last 7 days';
    if (_rangeDays == 14) return 'Last 14 days';
    if (_range.start == _range.end) return _dayLabel(_range.start);
    return '${_dayLabel(_range.start)} – ${_dayLabel(_range.end)}';
  }

  // --- Selected period stats ---

  _PeriodStats _statsFor(DateTimeRange r) {
    final sessions = widget.sessions.where((s) {
      final d = _d(s.startTime);
      return !d.isBefore(r.start) && !d.isAfter(r.end);
    }).toList();

    final diapers = widget.diapers.where((d) {
      final day = _d(d.time);
      return !day.isBefore(r.start) && !day.isAfter(r.end);
    }).toList();

    final weights = widget.weights.where((w) {
      final day = _d(w.date);
      return !day.isBefore(r.start) && !day.isAfter(r.end);
    }).toList();

    final totalMins = sessions.fold(0, (sum, s) => sum + s.duration.inMinutes);

    int? weightDiff;
    if (weights.length >= 2) {
      final sorted = [...weights]..sort((a, b) => a.date.compareTo(b.date));
      weightDiff = sorted.last.grams - sorted.first.grams;
    } else if (weights.length == 1) {
      weightDiff = null;
    }

    return _PeriodStats(
      totalMinutes: totalMins,
      diaperCount: diapers.length,
      weightDiffGrams: weightDiff,
      hasWeightData: weights.isNotEmpty,
    );
  }


  // ---------------------------------------------------------------------------
  // Range picker
  // ---------------------------------------------------------------------------

  void _openRangePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RangePickerSheet(
        current: _range,
        onSelect: (r) => setState(() {
          _range = r;
          _selectedBarIndex = null;
          _rebuildCache();
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bars = _cachedBars;
    final maxMin = _cachedMaxMin;
    final step = _labelStep(bars.length);
    final stats = _cachedStats;
    final isEmpty = bars.every((b) => b.minutes == 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nursing History',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      )),
              GestureDetector(
                onTap: _openRangePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_rangeTitle,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                              )),
                      const SizedBox(width: 2),
                      const Icon(Icons.expand_more, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),

        // Chart card
        NpCard(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.stackLg, AppSpacing.stackLg, AppSpacing.stackLg, AppSpacing.stackMd),
          child: Column(
            children: [
              if (isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackLg),
                  child: Center(
                    child: Text('No sessions in this period',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            )),
                  ),
                )
              else
                _InteractiveBarChart(
                  bars: bars,
                  maxMinutes: maxMin,
                  labelStep: step,
                  selectedIndex: _selectedBarIndex,
                  onBarTap: (i) => setState(() {
                    _selectedBarIndex = _selectedBarIndex == i ? null : i;
                    _rebuildStats();
                  }),
                ),
              if (_rangeDays == 1 && !isEmpty) ...[
                const SizedBox(height: AppSpacing.stackMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: AppColors.primaryContainer, label: 'Daytime'),
                    const SizedBox(width: AppSpacing.gutter),
                    _LegendDot(
                        color: AppColors.tertiary.withValues(alpha: 0.65),
                        label: 'Night (12a–6a)'),
                  ],
                ),
              ],
              if (!isEmpty) ...[
                const Divider(color: AppColors.surfaceContainerHigh, height: AppSpacing.stackLg * 2),
                if (_selectedBarIndex != null) ...[
                  Text(
                    _cachedBars[_selectedBarIndex!].label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                ],
                Row(
                  children: [
                    Expanded(child: _MiniStatCard(
                      icon: Icons.water_drop_outlined,
                      label: 'Total nursing',
                      value: _fmtMins(stats.totalMinutes),
                      color: AppColors.primary,
                    )),
                    const SizedBox(width: AppSpacing.stackMd),
                    Expanded(child: _MiniStatCard(
                      icon: Icons.child_care_outlined,
                      label: 'Diapers',
                      value: stats.diaperCount.toString(),
                      color: AppColors.tertiary,
                    )),
                    const SizedBox(width: AppSpacing.stackMd),
                    Expanded(child: _MiniStatCard(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Weight',
                      value: stats.hasWeightData
                          ? (stats.weightDiffGrams != null
                              ? '${stats.weightDiffGrams! >= 0 ? '+' : ''}${stats.weightDiffGrams}g'
                              : '—')
                          : '—',
                      color: AppColors.secondary,
                    )),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _fmtMins(int mins) {
    if (mins == 0) return '0m';
    if (mins < 60) return '${mins}m';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

// ---------------------------------------------------------------------------
// Interactive bar chart — widget tree, no CustomPainter
// Each bar is a GestureDetector → no animation rebuild on tap
// ---------------------------------------------------------------------------

class _InteractiveBarChart extends StatefulWidget {
  const _InteractiveBarChart({
    required this.bars,
    required this.maxMinutes,
    required this.labelStep,
    required this.selectedIndex,
    required this.onBarTap,
  });

  final List<_BarData> bars;
  final int maxMinutes;
  final int labelStep;
  final int? selectedIndex;
  final void Function(int) onBarTap;

  @override
  State<_InteractiveBarChart> createState() => _InteractiveBarChartState();
}

class _InteractiveBarChartState extends State<_InteractiveBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_InteractiveBarChart old) {
    super.didUpdateWidget(old);
    // Compare by value, not reference — bars getter creates a new list every build
    if (!_barsEqual(old.bars, widget.bars)) {
      _ctrl.forward(from: 0);
    }
  }

  bool _barsEqual(List<_BarData> a, List<_BarData> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].minutes != b[i].minutes || a[i].label != b[i].label) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (ctx, child) {
          return SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.bars.length, (i) {
                final bar = widget.bars[i];
                final frac = widget.maxMinutes == 0
                    ? 0.0
                    : (bar.minutes / widget.maxMinutes) * _anim.value;
                final isSelected = widget.selectedIndex == i;
                final hasSelection = widget.selectedIndex != null;

                final baseColor = bar.isNight
                    ? AppColors.tertiary.withValues(alpha: 0.65)
                    : AppColors.primaryContainer;
                final color = hasSelection && !isSelected
                    ? baseColor.withValues(alpha: 0.35)
                    : isSelected
                        ? AppColors.primary
                        : baseColor;

                final showLabel = i % widget.labelStep == 0 ||
                    i == widget.bars.length - 1;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onBarTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: frac.clamp(0.0, 1.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(AppRadius.md),
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.30),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 12,
                            child: showLabel
                                ? Text(
                                    bar.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontSize: 9,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.onSurfaceVariant,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : null,
                                        ),
                                    overflow: TextOverflow.clip,
                                    textAlign: TextAlign.center,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini stat card (below chart)
// ---------------------------------------------------------------------------

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppSpacing.stackSm),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  )),
          const SizedBox(height: 2),
          Text(value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                  )),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Range picker sheet
// ---------------------------------------------------------------------------

class _RangePickerSheet extends StatelessWidget {
  const _RangePickerSheet({required this.current, required this.onSelect});
  final DateTimeRange current;
  final void Function(DateTimeRange) onSelect;

  DateTimeRange _quick(int days) {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    final start = days == 1 ? end : end.subtract(Duration(days: days - 1));
    return DateTimeRange(start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final chips = [
      ('Today', _quick(1)),
      ('Yesterday', DateTimeRange(start: yesterday, end: yesterday)),
      ('Last 7 days', _quick(7)),
      ('Last 14 days', _quick(14)),
    ];

    return Container(
      margin: const EdgeInsets.all(AppSpacing.gutter),
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Period',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.stackLg),
          Wrap(
            spacing: AppSpacing.stackMd,
            runSpacing: AppSpacing.stackMd,
            children: chips.map((c) {
              final (label, range) = c;
              final sel = current.start == range.start && current.end == range.end;
              return GestureDetector(
                onTap: () {
                  onSelect(range);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                        color: sel ? AppColors.primary : AppColors.outlineVariant),
                  ),
                  child: Text(label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: sel ? AppColors.onPrimary : AppColors.onSurface,
                          )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          const Divider(color: AppColors.outlineVariant),
          const SizedBox(height: AppSpacing.stackMd),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full)),
                foregroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: const Text('Custom range'),
              onPressed: () async {
                Navigator.pop(context);
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                  initialDateRange: current,
                  builder: (ctx2, child) => Theme(
                    data: Theme.of(ctx2).copyWith(
                      colorScheme: Theme.of(ctx2).colorScheme.copyWith(
                            primary: AppColors.primary,
                            onPrimary: AppColors.onPrimary,
                            surface: AppColors.surfaceContainerLowest,
                          ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) onSelect(picked);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _BarData {
  const _BarData({
    required this.label,
    required this.minutes,
    required this.isNight,
    required this.periodStart,
    required this.periodEnd,
  });

  final String label;
  final int minutes;
  final bool isNight;
  final DateTime periodStart;
  final DateTime periodEnd;

  _BarData add(int mins) => _BarData(
        label: label,
        minutes: minutes + mins,
        isNight: isNight,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
}

class _PeriodStats {
  const _PeriodStats({
    required this.totalMinutes,
    required this.diaperCount,
    required this.weightDiffGrams,
    required this.hasWeightData,
  });

  final int totalMinutes;
  final int diaperCount;
  final int? weightDiffGrams;
  final bool hasWeightData;
}
