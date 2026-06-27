import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as fow;
import 'package:shared_preferences/shared_preferences.dart';

const _kNotifEnabled = 'np_notif_enabled';
const _kOverlayEnabled = 'np_overlay_enabled';

// ---------------------------------------------------------------------------
// Foreground task handler — runs in isolate, ticks every second
// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
void startForegroundCallback() {
  FlutterForegroundTask.setTaskHandler(_NursingTaskHandler());
}

class _NursingTaskHandler extends TaskHandler {
  int _elapsed = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _elapsed = await FlutterForegroundTask.getData<int>(key: 'elapsed') ?? 0;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _elapsed++;
    FlutterForegroundTask.saveData(key: 'elapsed', value: _elapsed);
    FlutterForegroundTask.updateService(
      notificationText: _fmt(_elapsed),
    );
    FlutterForegroundTask.sendDataToMain(_elapsed);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'finish') {
      FlutterForegroundTask.sendDataToMain('finish');
    }
  }

  String _fmt(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ---------------------------------------------------------------------------
// Public service API
// ---------------------------------------------------------------------------

class NursingSessionService {
  NursingSessionService._();
  static final instance = NursingSessionService._();

  static void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'nursing_timer',
        channelName: 'Nursing Timer',
        channelDescription: 'Shows the active nursing session timer',
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
      ),
    );
  }

  Future<bool> get isNotifEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotifEnabled) ?? true;
  }

  Future<bool> get isOverlayEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOverlayEnabled) ?? true;
  }

  Future<void> setNotifEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifEnabled, value);
  }

  Future<void> setOverlayEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOverlayEnabled, value);
  }

  Future<void> start({
    required int elapsedSeconds,
    required BuildContext context,
    required String notifTitle,
    required String notifFinishLabel,
    required String overlayContent,
  }) async {
    final notif = await isNotifEnabled;
    final overlay = await isOverlayEnabled;
    if (notif) {
      await FlutterForegroundTask.requestNotificationPermission();
      await _startForeground(
        elapsedSeconds,
        notifTitle: notifTitle,
        notifFinishLabel: notifFinishLabel,
      );
    }
    if (overlay && context.mounted) {
      await _showOverlay(context, overlayContent: overlayContent);
      fow.FlutterOverlayWindow.shareData({'elapsed': elapsedSeconds});
    }
  }

  Future<void> stop() async {
    await _stopForeground();
    await _hideOverlay();
  }

  Future<void> updateElapsed(int seconds) async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.saveData(key: 'elapsed', value: seconds);
    }
    if (await fow.FlutterOverlayWindow.isActive()) {
      fow.FlutterOverlayWindow.shareData({'elapsed': seconds});
    }
  }

  // ---- foreground ----

  Future<void> _startForeground(
    int elapsedSeconds, {
    required String notifTitle,
    required String notifFinishLabel,
  }) async {
    await FlutterForegroundTask.saveData(key: 'elapsed', value: elapsedSeconds);
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        serviceId: 1001,
        notificationTitle: notifTitle,
        notificationText: '00:00',
        callback: startForegroundCallback,
        notificationButtons: [
          NotificationButton(id: 'finish', text: notifFinishLabel),
        ],
      );
    }
  }

  Future<void> _stopForeground() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  // ---- overlay ----

  Future<void> _showOverlay(
    BuildContext context, {
    required String overlayContent,
  }) async {
    final granted = await fow.FlutterOverlayWindow.isPermissionGranted();
    if (!granted) {
      final result = await fow.FlutterOverlayWindow.requestPermission();
      if (result != true) return;
    }
    if (!await fow.FlutterOverlayWindow.isActive()) {
      await fow.FlutterOverlayWindow.showOverlay(
        height: 120,
        width: 440,
        alignment: fow.OverlayAlignment.topCenter,
        flag: fow.OverlayFlag.defaultFlag,
        overlayTitle: 'Nursing Pulse',
        overlayContent: overlayContent,
        visibility: fow.NotificationVisibility.visibilitySecret,
        enableDrag: true,
        positionGravity: fow.PositionGravity.none,
        startPosition: const fow.OverlayPosition(0, 200),
      );
    }
  }

  Future<void> _hideOverlay() async {
    if (await fow.FlutterOverlayWindow.isActive()) {
      await fow.FlutterOverlayWindow.closeOverlay();
    }
  }
}
