import 'package:flutter/material.dart';

import 'screens/analytics_screen.dart';
import 'screens/clean_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/doctor_screen.dart';
import 'screens/settings_screen.dart';
import 'services/widget_sync_service.dart';
import 'theme/app_theme.dart';
import 'widgets/sidebar_nav.dart';

class FCleanerApp extends StatefulWidget {
  const FCleanerApp({super.key});

  @override
  State<FCleanerApp> createState() => _FCleanerAppState();
}

class _FCleanerAppState extends State<FCleanerApp> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetSyncService.instance.initialize(
      navigationHandler: _onNavigate,
    );
  }

  void _onNavigate(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: Row(
        children: [
          SidebarNav(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onNavigate,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _buildScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    return switch (_selectedIndex) {
      0 => DashboardScreen(
        key: const ValueKey('dashboard'),
        onNavigate: _onNavigate,
      ),
      1 => CleanScreen(
        key: const ValueKey('clean'),
        onNavigateToAnalytics: () => _onNavigate(2),
      ),
      2 => const AnalyticsScreen(key: ValueKey('analytics')),
      3 => const DoctorScreen(key: ValueKey('doctor')),
      4 => const SettingsScreen(key: ValueKey('settings')),
      _ => DashboardScreen(
        key: const ValueKey('dashboard'),
        onNavigate: _onNavigate,
      ),
    };
  }
}
