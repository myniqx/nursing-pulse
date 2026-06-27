import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nursing_pulse/l10n/app_localizations.dart';
import '../../data/models/baby_profile.dart';
import '../../data/models/diaper_log.dart';
import '../../data/models/session.dart';
import '../../data/repositories/baby_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../services/nursing_session_service.dart';
import '../../shared/app_theme.dart';
import '../../shared/widgets/np_card.dart';
import '../../shared/widgets/np_chip.dart';
import '../../shared/widgets/np_stat_tile.dart';
import '../../shared/widgets/session_editor_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = SessionRepository();
  final _babyRepo = BabyRepository();

  Session? _activeSession;
  List<Session> _sessions = [];
  List<DiaperLog> _diapers = [];
  NursingSide _selectedSide = NursingSide.left;
  BabyProfile? _profile;
  Timer? _ticker;
  final _receivePort = ReceivePort();

  static const _kPortName = 'NP_MAIN';

  @override
  void initState() {
    super.initState();
    _load();
    FlutterForegroundTask.addTaskDataCallback(_onForegroundData);
    _receivePort.listen((message) {
      if (message == 'finish' && _activeSession != null) {
        _finishNursing();
      }
    });
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, _kPortName);
  }

  void _onForegroundData(dynamic data) {
    if (data == 'finish' && _activeSession != null) {
      _finishNursing();
    }
  }

  Future<void> _load() async {
    final active = await _repo.getActiveSession();
    final sessions = await _repo.getSessions();
    final profile = await _babyRepo.getProfile();
    final diapers = await _babyRepo.getDiapers();
    setState(() {
      _activeSession = active;
      _sessions = sessions;
      _profile = profile;
      _diapers = diapers;
      if (active != null) {
        _selectedSide = active.side;
        _startTicker();
      }
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
      if (_activeSession != null) {
        final elapsed = DateTime.now().difference(_activeSession!.startTime).inSeconds;
        NursingSessionService.instance.updateElapsed(elapsed);
      }
    });
  }

  Future<void> _startNursing() async {
    final session = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      side: _selectedSide,
    );
    await _repo.startSession(session);
    setState(() => _activeSession = session);
    _startTicker();
    if (mounted) {
      await NursingSessionService.instance.start(
        elapsedSeconds: 0,
        context: context,
      );
    }
  }

  Future<void> _switchSide(NursingSide newSide) async {
    if (_activeSession == null || _activeSession!.side == newSide) return;
    HapticFeedback.lightImpact();

    final finished = await _repo.finishActiveSession(DateTime.now());
    final sessions = await _repo.getSessions();

    final newSession = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      side: newSide,
    );
    await _repo.startSession(newSession);

    setState(() {
      _sessions = sessions;
      _activeSession = newSession;
      _selectedSide = newSide;
    });
    debugPrint('Switched side, prev session: ${finished.id}');
  }

  Future<void> _finishNursing() async {
    _ticker?.cancel();
    final elapsed = _activeSession != null
        ? DateTime.now().difference(_activeSession!.startTime)
        : Duration.zero;

    if (elapsed.inSeconds < 15) {
      await _repo.discardActiveSession();
      await NursingSessionService.instance.stop();
      setState(() => _activeSession = null);
      return;
    }

    final finished = await _repo.finishActiveSession(DateTime.now());
    final sessions = await _repo.getSessions();
    setState(() {
      _activeSession = null;
      _sessions = [finished, ...sessions.where((s) => s.id != finished.id)];
    });
    await NursingSessionService.instance.stop();
  }

  Future<void> _selectSide(NursingSide side) async {
    if (_activeSession != null) {
      await _switchSide(side);
    } else {
      setState(() => _selectedSide = side);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showAddSessionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SessionEditorSheet(
        onSave: (session) async {
          await _repo.saveSession(session);
          await _load();
        },
      ),
    );
  }

  void _showSessionsSheet(AppLocalizations l10n) {
    final today = DateTime.now();
    final todaySessions = _sessions
        .where((s) =>
            !s.isActive &&
            s.startTime.year == today.year &&
            s.startTime.month == today.month &&
            s.startTime.day == today.day)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TodaySessionsSheet(sessions: todaySessions),
    );
  }

  String _lastNursingText(AppLocalizations l10n) {
    final completed = _sessions.where((s) => !s.isActive).toList();
    if (completed.isEmpty) return l10n.lastNursingNoSessions;
    final last = completed.first;
    final ago = DateTime.now().difference(last.endTime!);
    final side = last.side == NursingSide.left ? l10n.sideLeftFull : l10n.sideRightFull;
    final duration = last.duration.inMinutes;
    if (ago.inMinutes < 60) {
      return l10n.lastNursingMinAgo(ago.inMinutes, side, duration);
    }
    return l10n.lastNursingHourAgo(ago.inHours, ago.inMinutes % 60, side, duration);
  }

  String? _nextFeedSuggestion(AppLocalizations l10n) {
    final completed = _sessions.where((s) => !s.isActive).toList();
    if (completed.isEmpty) return null;

    final lastEnd = completed.first.endTime!;
    final intervalHours = _profile?.effectiveIntervalHours ?? 3.0;
    final suggested = lastEnd.add(Duration(minutes: (intervalHours * 60).round()));

    if (suggested.isBefore(DateTime.now())) return l10n.diaperJustNow;

    final h = suggested.hour % 12 == 0 ? 12 : suggested.hour % 12;
    final m = suggested.minute.toString().padLeft(2, '0');
    final period = suggested.hour >= 12 ? 'PM' : 'AM';
    return l10n.nextFeedAround('$h:$m $period');
  }

  int get _todayDiaperCount {
    final today = DateTime.now();
    return _diapers
        .where((d) =>
            d.time.year == today.year &&
            d.time.month == today.month &&
            d.time.day == today.day)
        .length;
  }

  int get _dailyTotalMinutes {
    final today = DateTime.now();
    return _sessions
        .where((s) =>
            !s.isActive &&
            s.startTime.year == today.year &&
            s.startTime.month == today.month &&
            s.startTime.day == today.day)
        .fold(0, (sum, s) => sum + s.duration.inMinutes);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _receivePort.close();
    IsolateNameServer.removePortNameMapping(_kPortName);
    FlutterForegroundTask.removeTaskDataCallback(_onForegroundData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNursing = _activeSession != null;
    final elapsed = isNursing ? _activeSession!.duration : Duration.zero;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.stackMd,
        AppSpacing.containerPadding,
        80,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _LastNursingNote(
                  text: _lastNursingText(l10n),
                  onTap: _sessions.any((s) => !s.isActive)
                      ? () => _showSessionsSheet(l10n)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.stackMd),
              GestureDetector(
                onTap: () => _showAddSessionSheet(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.add, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackLg),
          _TimerSection(
            isNursing: isNursing,
            elapsed: elapsed,
            formattedTime: _formatDuration(elapsed),
            selectedSide: _selectedSide,
            onStart: _startNursing,
            onFinish: _finishNursing,
            onSideChanged: _selectSide,
          ),
          const SizedBox(height: AppSpacing.stackLg),
          _StatsGrid(
            dailyTotalMinutes: _dailyTotalMinutes,
            todayDiaperCount: _todayDiaperCount,
            nextFeedSuggestion: _nextFeedSuggestion(l10n),
          ),
        ],
      ),
    );
  }
}

class _LastNursingNote extends StatelessWidget {
  const _LastNursingNote({required this.text, this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: NpCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.gutter),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lastNursingLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: AppSpacing.stackSm),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 18),
        ],
      ),
      ),
    );
  }
}

class _TodaySessionsSheet extends StatelessWidget {
  const _TodaySessionsSheet({required this.sessions});
  final List<Session> sessions;

  String _timeLabel(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(l10n.statsTodaySessions,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.stackLg),
          if (sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackLg),
              child: Text(l10n.statsNoSessionsToday,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      )),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: sessions.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              final isLeft = s.side == NursingSide.left;
              final color = isLeft ? AppColors.primary : AppColors.tertiary;
              final sideLabel = isLeft ? l10n.sideLeftFull : l10n.sideRightFull;
              return Column(
                children: [
                  Padding(
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
                          child: Icon(Icons.water_drop, size: 20, color: color),
                        ),
                        const SizedBox(width: AppSpacing.stackMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sideLabel,
                                  style: Theme.of(context).textTheme.labelLarge),
                              Text(_timeLabel(s.startTime),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant,
                                      )),
                            ],
                          ),
                        ),
                        Text(
                          '${s.duration.inMinutes} min',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (i < sessions.length - 1)
                    const Divider(color: AppColors.surfaceContainerHigh, height: 1),
                ],
              );
            }).toList(),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.stackMd),
        ],
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  const _TimerSection({
    required this.isNursing,
    required this.elapsed,
    required this.formattedTime,
    required this.selectedSide,
    required this.onStart,
    required this.onFinish,
    required this.onSideChanged,
  });

  final bool isNursing;
  final Duration elapsed;
  final String formattedTime;
  final NursingSide selectedSide;
  final VoidCallback onStart;
  final VoidCallback onFinish;
  final ValueChanged<NursingSide> onSideChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const ringSize = 280.0;
    const strokeWidth = 8.0;
    const radius = (ringSize / 2) - strokeWidth;
    final circumference = 2 * math.pi * radius;
    const cycleSecs = 300.0;
    final progress = isNursing ? (elapsed.inSeconds % cycleSecs) / cycleSecs : 0.0;

    return Column(
      children: [
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(ringSize, ringSize),
                painter: _RingPainter(
                  progress: progress,
                  circumference: circumference,
                  radius: radius,
                  strokeWidth: strokeWidth,
                ),
              ),
              GestureDetector(
                onTap: isNursing ? null : onStart,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: isNursing ? AppColors.primaryContainer : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isNursing) ...[
                        const Icon(Icons.play_arrow, size: 48, color: AppColors.onPrimary),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          l10n.startNursing,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.onPrimary,
                              ),
                        ),
                      ] else ...[
                        Text(
                          formattedTime,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppColors.onPrimaryContainer,
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          selectedSide == NursingSide.left
                              ? l10n.sideLeftFull
                              : l10n.sideRightFull,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.onPrimaryContainer.withValues(alpha: 0.80),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isNursing) ...[
          const SizedBox(height: AppSpacing.stackLg),
          GestureDetector(
            onTap: onFinish,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                l10n.finishSession,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onTertiaryContainer,
                    ),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.stackLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NpChip(
              label: l10n.sideLeft,
              selected: selectedSide == NursingSide.left,
              onTap: () => onSideChanged(NursingSide.left),
            ),
            const SizedBox(width: AppSpacing.gutter),
            NpChip(
              label: l10n.sideRight,
              selected: selectedSide == NursingSide.right,
              onTap: () => onSideChanged(NursingSide.right),
            ),
          ],
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.circumference,
    required this.radius,
    required this.strokeWidth,
  });

  final double progress;
  final double circumference;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.dailyTotalMinutes,
    required this.todayDiaperCount,
    required this.nextFeedSuggestion,
  });
  final int dailyTotalMinutes;
  final int todayDiaperCount;
  final String? nextFeedSuggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NpStatTile(
                icon: Icons.water_drop_outlined,
                label: l10n.dailyTotal,
                value: dailyTotalMinutes.toString(),
                unit: 'min',
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.gutter),
            Expanded(
              child: NpStatTile(
                icon: Icons.child_care_outlined,
                label: l10n.diapers,
                value: todayDiaperCount.toString(),
                unit: l10n.navHome == 'Home' ? 'today' : '',
                iconColor: AppColors.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gutter),
        NpCard(
          color: AppColors.secondaryContainer.withValues(alpha: 0.30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nextSuggestedFeed,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  Text(
                    nextFeedSuggestion ?? l10n.lastNursingNoSessions,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.schedule, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

