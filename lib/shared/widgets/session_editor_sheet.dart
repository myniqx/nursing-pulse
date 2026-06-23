import 'package:flutter/material.dart';
import '../../data/models/session.dart';
import '../../l10n/app_localizations.dart';
import '../app_theme.dart';
import 'np_card.dart';
import 'np_chip.dart';

class SessionEditorSheet extends StatefulWidget {
  const SessionEditorSheet({
    super.key,
    this.session,
    required this.onSave,
  });

  // null = add mode, non-null = edit mode
  final Session? session;
  final void Function(Session) onSave;

  @override
  State<SessionEditorSheet> createState() => _SessionEditorSheetState();
}

class _SessionEditorSheetState extends State<SessionEditorSheet> {
  late DateTime _startTime;
  late DateTime _endTime;
  late NursingSide _side;

  bool get _isEditMode => widget.session != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _startTime = widget.session!.startTime;
      _endTime = widget.session!.endTime ?? DateTime.now();
      _side = widget.session!.side;
    } else {
      final now = DateTime.now();
      _endTime = now;
      _startTime = now.subtract(const Duration(minutes: 10));
      _side = NursingSide.left;
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked == null) return;
    final updated = DateTime(
      initial.year, initial.month, initial.day,
      picked.hour, picked.minute,
    );
    setState(() {
      if (isStart) {
        _startTime = updated;
      } else {
        _endTime = updated;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final durMin = _endTime.difference(_startTime).inMinutes.clamp(0, 999);

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
          Text(
            _isEditMode ? l10n.statsEditSession : l10n.sessionAddTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.stackLg),
          if (_isEditMode) ...[
            Text(
              l10n.statsEditHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.stackLg),
          ],
          Row(
            children: [
              Expanded(child: _TimeCard(
                label: l10n.statsStart,
                time: _startTime,
                onTap: () => _pickTime(true),
              )),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(child: _TimeCard(
                label: l10n.statsEnd,
                time: _endTime,
                onTap: () => _pickTime(false),
              )),
            ],
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Text(
            l10n.statsDuration(durMin),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NpChip(
                label: l10n.sideLeft,
                selected: _side == NursingSide.left,
                onTap: () => setState(() => _side = NursingSide.left),
              ),
              const SizedBox(width: AppSpacing.gutter),
              NpChip(
                label: l10n.sideRight,
                selected: _side == NursingSide.right,
                onTap: () => setState(() => _side = NursingSide.right),
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
              ),
              onPressed: durMin <= 0
                  ? null
                  : () {
                      final session = _isEditMode
                          ? widget.session!.copyWith(
                              startTime: _startTime,
                              endTime: _endTime,
                              side: _side,
                            )
                          : Session(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              startTime: _startTime,
                              side: _side,
                              endTime: _endTime,
                            );
                      widget.onSave(session);
                      Navigator.pop(context);
                    },
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final DateTime time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NpCard(
        borderColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        )),
                const SizedBox(width: 4),
                const Icon(Icons.edit_outlined, size: 10, color: AppColors.onSurfaceVariant),
              ],
            ),
            Text(
              TimeOfDay.fromDateTime(time).format(context),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
