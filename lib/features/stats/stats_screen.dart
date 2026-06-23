import 'package:flutter/material.dart';
import '../../data/models/diaper_log.dart';
import '../../data/models/session.dart';
import '../../data/models/weight_entry.dart';
import '../../data/repositories/baby_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../shared/app_theme.dart';
import '../../shared/widgets/np_card.dart';
import '../../shared/widgets/np_stat_tile.dart';
import '../../shared/widgets/weight_chart.dart';
import 'nursing_history_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _sessionRepo = SessionRepository();
  final _babyRepo = BabyRepository();

  List<Session> _sessions = [];
  List<DiaperLog> _diapers = [];
  List<WeightEntry> _weights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await _sessionRepo.getSessions();
    final diapers = await _babyRepo.getDiapers();
    final weights = await _babyRepo.getWeights();
    setState(() {
      _sessions = sessions.where((s) => !s.isActive).toList();
      _diapers = diapers;
      _weights = weights;
      _loading = false;
    });
  }

  List<Session> get _todaySessions {
    final today = DateTime.now();
    return _sessions.where((s) =>
        s.startTime.year == today.year &&
        s.startTime.month == today.month &&
        s.startTime.day == today.day).toList();
  }

  int get _dailyTotalMinutes =>
      _todaySessions.fold(0, (sum, s) => sum + s.duration.inMinutes);

  double get _leftPercent {
    if (_todaySessions.isEmpty) return 0.5;
    final leftMin = _todaySessions
        .where((s) => s.side == NursingSide.left)
        .fold(0, (sum, s) => sum + s.duration.inMinutes);
    return leftMin / _dailyTotalMinutes;
  }

  int get _nightFeedCount {
    return _todaySessions.where((s) {
      final h = s.startTime.hour;
      return h >= 0 && h < 6;
    }).length;
  }

  double get _avgDurationMinutes {
    if (_todaySessions.isEmpty) return 0;
    return _dailyTotalMinutes / _todaySessions.length;
  }

  String _timeLabel(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:$m $period';
  }

  String _sideLabel(NursingSide side) =>
      side == NursingSide.left ? 'Left Side' : 'Right Side';

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
            _SummaryHeader(totalMinutes: _dailyTotalMinutes),
            const SizedBox(height: AppSpacing.stackLg),
            if (_todaySessions.isNotEmpty) ...[
              _LateralBalanceCard(leftPercent: _leftPercent, sessions: _todaySessions),
              const SizedBox(height: AppSpacing.stackLg),
            ],
            _SessionHistoryCard(
              sessions: _todaySessions,
              timeLabel: _timeLabel,
              sideLabel: _sideLabel,
              onEdit: _showEditSheet,
            ),
            const SizedBox(height: AppSpacing.stackLg),
            _InsightsBento(
              avgMinutes: _avgDurationMinutes,
              nightFeeds: _nightFeedCount,
            ),
            const SizedBox(height: AppSpacing.stackLg),
            NursingHistoryChart(
              sessions: _sessions,
              diapers: _diapers,
              weights: _weights,
            ),
            const SizedBox(height: AppSpacing.stackLg),
            WeightChart(weights: _weights),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(Session session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSessionSheet(
        session: session,
        onSave: (updated) async {
          await _sessionRepo.updateSession(updated);
          await _load();
        },
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.totalMinutes});
  final int totalMinutes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Summary",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          totalMinutes == 0
              ? 'No sessions yet'
              : '${totalMinutes ~/ 60 > 0 ? '${totalMinutes ~/ 60}h ' : ''}${totalMinutes % 60 > 0 ? '${totalMinutes % 60}m' : ''}',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
              ),
        ),
        if (totalMinutes > 0)
          Text(
            'total nursing today',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
      ],
    );
  }
}

class _LateralBalanceCard extends StatelessWidget {
  const _LateralBalanceCard({
    required this.leftPercent,
    required this.sessions,
  });

  final double leftPercent;
  final List<Session> sessions;

  int _minutesFor(NursingSide side) => sessions
      .where((s) => s.side == side)
      .fold(0, (sum, s) => sum + s.duration.inMinutes);

  String _fmt(int m) {
    if (m < 60) return '${m}m';
    return '${m ~/ 60}h ${m % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final leftMin = _minutesFor(NursingSide.left);
    final rightMin = _minutesFor(NursingSide.right);
    final leftPct = (leftPercent * 100).round();
    final rightPct = 100 - leftPct;

    return NpCard(
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LATERAL BALANCE',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
              ),
              const Icon(Icons.balance, color: AppColors.tertiary),
            ],
          ),
          const SizedBox(height: AppSpacing.stackMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: leftPct > 0 ? leftPct : 1,
                    child: Container(
                        color: AppColors.primaryContainer.withValues(alpha: 0.70)),
                  ),
                  Expanded(
                    flex: rightPct > 0 ? rightPct : 1,
                    child: Container(
                        color: AppColors.tertiaryContainer.withValues(alpha: 0.70)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Left Side',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            )),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '$leftPct%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primaryContainer,
                              ),
                        ),
                        TextSpan(
                          text: '  ${_fmt(leftMin)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Right Side',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            )),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '$rightPct%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.tertiaryContainer,
                              ),
                        ),
                        TextSpan(
                          text: '  ${_fmt(rightMin)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionHistoryCard extends StatelessWidget {
  const _SessionHistoryCard({
    required this.sessions,
    required this.timeLabel,
    required this.sideLabel,
    required this.onEdit,
  });

  final List<Session> sessions;
  final String Function(DateTime) timeLabel;
  final String Function(NursingSide) sideLabel;
  final void Function(Session) onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Today\'s Sessions',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        NpCard(
          padding: const EdgeInsets.all(AppSpacing.stackLg),
          child: sessions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.stackLg),
                    child: Text(
                      'No sessions recorded today',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              : Column(
                  children: sessions.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final isLeft = s.side == NursingSide.left;
                    final color = isLeft ? AppColors.primary : AppColors.tertiary;
                    return Column(
                      children: [
                        GestureDetector(
                          onLongPress: () => onEdit(s),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.10),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.water_drop,
                                      size: 20, color: color),
                                ),
                                const SizedBox(width: AppSpacing.stackMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(sideLabel(s.side),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge),
                                      Text(
                                        timeLabel(s.startTime),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 12,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${s.duration.inMinutes} min',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: AppColors.primary),
                                    ),
                                    Text(
                                      'hold to edit',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                              color: AppColors.onSurfaceVariant
                                                  .withValues(alpha: 0.5)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (i < sessions.length - 1)
                          const Divider(
                              color: AppColors.surfaceContainerHigh, height: 1),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _InsightsBento extends StatelessWidget {
  const _InsightsBento({
    required this.avgMinutes,
    required this.nightFeeds,
  });

  final double avgMinutes;
  final int nightFeeds;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NpStatTile(
            icon: Icons.schedule,
            label: 'Avg. Duration',
            value: avgMinutes == 0 ? '--' : avgMinutes.toStringAsFixed(1),
            unit: 'min',
            iconColor: AppColors.primary,
            color: AppColors.secondaryContainer.withValues(alpha: 0.30),
            borderColor: AppColors.outlineVariant.withValues(alpha: 0.30),
          ),
        ),
        const SizedBox(width: AppSpacing.gutter),
        Expanded(
          child: NpStatTile(
            icon: Icons.nightlight_outlined,
            label: 'Night Feeds',
            value: nightFeeds.toString(),
            unit: 'times',
            iconColor: AppColors.tertiary,
            color: AppColors.tertiaryContainer.withValues(alpha: 0.10),
            borderColor: AppColors.outlineVariant.withValues(alpha: 0.30),
          ),
        ),
      ],
    );
  }
}

class _EditSessionSheet extends StatefulWidget {
  const _EditSessionSheet({required this.session, required this.onSave});
  final Session session;
  final void Function(Session) onSave;

  @override
  State<_EditSessionSheet> createState() => _EditSessionSheetState();
}

class _EditSessionSheetState extends State<_EditSessionSheet> {
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _endTime = widget.session.endTime ?? DateTime.now();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );
    if (picked != null) {
      setState(() {
        _endTime = DateTime(
          _endTime.year,
          _endTime.month,
          _endTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dur = _endTime.difference(widget.session.startTime);
    final durMin = dur.inMinutes.clamp(0, 999);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.gutter),
      padding: EdgeInsets.only(
        left: AppSpacing.stackLg,
        right: AppSpacing.stackLg,
        top: AppSpacing.stackLg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.stackLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Session',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.stackLg),
          Text(
            'Adjust end time if you forgot to stop the timer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Row(
            children: [
              Expanded(
                child: NpCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              )),
                      Text(
                        TimeOfDay.fromDateTime(widget.session.startTime)
                            .format(context),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: GestureDetector(
                  onTap: _pickTime,
                  child: NpCard(
                    borderColor: AppColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End (tap to change)',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.primary)),
                        Text(
                          TimeOfDay.fromDateTime(_endTime).format(context),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Text(
            'Duration: $durMin min',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
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
                widget.onSave(widget.session.copyWith(endTime: _endTime));
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
