import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'shared/app_theme.dart';

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _OverlayApp());
}

class _OverlayApp extends StatefulWidget {
  const _OverlayApp();

  @override
  State<_OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<_OverlayApp> {
  int _elapsed = 0;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is Map && data['elapsed'] != null) {
        setState(() => _elapsed = data['elapsed'] as int);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _fmt(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: NursingBadge(
            formattedTime: _fmt(_elapsed),
            onOpenApp: () {
              FlutterOverlayWindow.shareData({'action': 'open_app'});
            },
            onFinish: () {
              HapticFeedback.lightImpact();
              FlutterOverlayWindow.shareData({'action': 'finish'});
            },
          ),
        ),
      ),
    );
  }
}

class NursingBadge extends StatelessWidget {
  const NursingBadge({
    super.key,
    required this.formattedTime,
    required this.onOpenApp,
    required this.onFinish,
  });

  final String formattedTime;
  final VoidCallback onOpenApp;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Open app button
            // Open app — same inset as finish button side
            GestureDetector(
              onTap: onOpenApp,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.onPrimary,
                  size: 24,
                ),
              ),
            ),
            // Timer
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Text(
                formattedTime,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                  height: 1,
                ),
              ),
            ),
            // Finish button
            GestureDetector(
              onTap: onFinish,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Text(
                  'Finish',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onTertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
