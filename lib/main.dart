import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:nursing_pulse/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/dev/mock_data_seeder.dart';
import 'services/nursing_session_service.dart';
import 'shared/app_theme.dart';
import 'shared/widgets/np_top_app_bar.dart';
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

  static const _screens = [
    HomeScreen(),
    StatsScreen(),
    BabyScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Listen for overlay actions (finish / open_app)
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is Map) {
        final action = data['action'];
        if (action == 'open_app') {
          setState(() => _currentIndex = 0);
        } else if (action == 'finish') {
          // HomeScreen handles finish via ForegroundTask data channel
        }
      }
    });
    // Listen for foreground task finish button
    FlutterForegroundTask.addTaskDataCallback((data) {
      if (data == 'finish') {
        setState(() => _currentIndex = 0);
      }
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NpTopAppBar(onSettingsTap: _openSettings),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _screens[_currentIndex],
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
