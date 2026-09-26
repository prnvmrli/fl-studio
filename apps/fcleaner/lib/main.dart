import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/clean_provider.dart';
import 'providers/doctor_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsProvider();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => CleanProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'FCleaner',
            debugShowCheckedModeBanner: false,
            theme: settings.isDarkMode
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            home: const FCleanerApp(),
          );
        },
      ),
    ),
  );
}
