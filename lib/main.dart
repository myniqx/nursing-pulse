import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'shared/dev_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:nursing_pulse/l10n/app_localizations.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/dev/mock_data_seeder.dart';
import 'services/nursing_session_service.dart';
import 'shared/app_theme.dart';
import 'shared/widgets/np_top_app_bar.dart';
import 'shared/widgets/nursing_badge.dart';
import 'shared/widgets/np_bottom_nav_bar.dart';
import 'features/home/home_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/baby/baby_screen.dart';
import 'features/settings/settings_screen.dart';

const _kLocaleKey = 'np_locale';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NursingSessionService.initForegroundTask();
  await MockDataSeeder.seedIfNeeded();
  runApp(const NursingPulseApp());
}

// ---------------------------------------------------------------------------
// Overlay entry point — runs in a separate Flutter engine while the app is in
// the background. MUST live in main.dart so the native side can resolve it and
// tree-shaking keeps it.
// ---------------------------------------------------------------------------

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
      home: Material(
        color: Colors.transparent,
        child: Center(
          child: NursingBadge(
            formattedTime: _fmt(_elapsed),
            onFinish: () {
              HapticFeedback.lightImpact();
              IsolateNameServer.lookupPortByName('NP_MAIN')?.send('finish');
            },
          ),
        ),
      ),
    );
  }
}

class NursingPulseApp extends StatefulWidget {
  const NursingPulseApp({super.key});

  static NursingPulseAppState of(BuildContext context) =>
      context.findAncestorStateOfType<NursingPulseAppState>()!;

  @override
  State<NursingPulseApp> createState() => NursingPulseAppState();
}

class NursingPulseAppState extends State<NursingPulseApp> {
  // null = follow system
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final tag = prefs.getString(_kLocaleKey);
    if (tag != null && tag != 'system') {
      setState(() => _locale = Locale(tag));
    }
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.setString(_kLocaleKey, 'system');
    } else {
      await prefs.setString(_kLocaleKey, locale.languageCode);
    }
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nursing Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('nl'),
      ],
      home: const _RootShell(),
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _currentIndex = 0;
  final _screenshotController = ScreenshotController();
  static const _screens = [
    HomeScreen(),
    StatsScreen(),
    BabyScreen(),
  ];

  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback((data) {
      if (data == 'finish') {
        setState(() => _currentIndex = 0);
      }
    });
  }

  Future<void> _captureScreenshot() async {
    final bytes = await _screenshotController.capture(pixelRatio: 1.0);
    if (bytes == null) return;
    final dir = Directory('screenshots');
    if (!dir.existsSync()) dir.createSync();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('screenshots/screenshot_$timestamp.png');
    await file.writeAsBytes(bytes);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NpTopAppBar(
        onSettingsTap: _openSettings,
        onIconTap: isDev ? _captureScreenshot : null,
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: ColoredBox(
          color: AppColors.surface,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _screens[_currentIndex],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NpBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.settingsTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
              ),
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const SettingsScreen(),
        ),
      ),
    );
  }
}
