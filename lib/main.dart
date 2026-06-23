import 'package:flutter/material.dart';
import 'data/dev/mock_data_seeder.dart';
import 'shared/app_theme.dart';
import 'shared/widgets/np_top_app_bar.dart';
import 'shared/widgets/np_bottom_nav_bar.dart';
import 'features/home/home_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/baby/baby_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MockDataSeeder.seedIfNeeded();
  runApp(const NursingPulseApp());
}

class NursingPulseApp extends StatelessWidget {
  const NursingPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nursing Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
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

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NpTopAppBar(onSettingsTap: _openSettings),
      // Scroll fix: body fills available space, each screen handles its own scroll
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Settings',
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
