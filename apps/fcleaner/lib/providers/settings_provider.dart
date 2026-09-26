import 'dart:convert';

import 'package:fclean/fclean.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider();

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  String _defaultScanPath = '';
  String get defaultScanPath => _defaultScanPath;

  CleanConfig _cleanConfig = const CleanConfig();
  CleanConfig get cleanConfig => _cleanConfig;

  AppConfig get appConfig => AppConfig(clean: _cleanConfig);

  // ── Cleanup history ──────────────────────────────────────────────
  List<CleanupRecord> _history = [];
  List<CleanupRecord> get history => List.unmodifiable(_history);

  int get totalBytesReclaimed =>
      _history.fold(0, (sum, r) => sum + r.bytesReclaimed);

  // ── Load / Save ──────────────────────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? true;
    _defaultScanPath = prefs.getString('defaultScanPath') ?? '';
    _cleanConfig = CleanConfig(
      gradle: prefs.getBool('clean.gradle') ?? true,
      xcode: prefs.getBool('clean.xcode') ?? true,
      cocoapods: prefs.getBool('clean.cocoapods') ?? true,
      trash: prefs.getBool('clean.trash') ?? false,
    );

    final historyJson = prefs.getStringList('cleanupHistory') ?? [];
    _history = historyJson
        .map(
          (json) =>
              CleanupRecord.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setString('defaultScanPath', _defaultScanPath);
    await prefs.setBool('clean.gradle', _cleanConfig.gradle);
    await prefs.setBool('clean.xcode', _cleanConfig.xcode);
    await prefs.setBool('clean.cocoapods', _cleanConfig.cocoapods);
    await prefs.setBool('clean.trash', _cleanConfig.trash);

    final historyJson = _history.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('cleanupHistory', historyJson);
  }

  // ── Setters ──────────────────────────────────────────────────────
  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    _save();
  }

  void setDefaultScanPath(String path) {
    _defaultScanPath = path;
    notifyListeners();
    _save();
  }

  void _updateConfig({bool? gradle, bool? xcode, bool? cocoapods, bool? trash}) {
    _cleanConfig = CleanConfig(
      gradle: gradle ?? _cleanConfig.gradle,
      xcode: xcode ?? _cleanConfig.xcode,
      cocoapods: cocoapods ?? _cleanConfig.cocoapods,
      trash: trash ?? _cleanConfig.trash,
    );
    notifyListeners();
    _save();
  }

  void setGradle(bool value) => _updateConfig(gradle: value);
  void setXcode(bool value) => _updateConfig(xcode: value);
  void setCocoapods(bool value) => _updateConfig(cocoapods: value);
  void setTrash(bool value) => _updateConfig(trash: value);

  void addCleanupRecord(CleanupRecord record) {
    _history.insert(0, record);
    // Keep last 50 records
    if (_history.length > 50) {
      _history = _history.sublist(0, 50);
    }
    notifyListeners();
    _save();
  }

  void clearHistory() {
    _history = [];
    notifyListeners();
    _save();
  }
}

// ── Cleanup history record ────────────────────────────────────────────
class CleanupRecord {
  const CleanupRecord({
    required this.timestamp,
    required this.bytesReclaimed,
    required this.targetsDeleted,
    required this.targetsSkipped,
    required this.wasDryRun,
  });

  final DateTime timestamp;
  final int bytesReclaimed;
  final int targetsDeleted;
  final int targetsSkipped;
  final bool wasDryRun;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'bytesReclaimed': bytesReclaimed,
    'targetsDeleted': targetsDeleted,
    'targetsSkipped': targetsSkipped,
    'wasDryRun': wasDryRun,
  };

  factory CleanupRecord.fromJson(Map<String, dynamic> json) {
    return CleanupRecord(
      timestamp: DateTime.parse(json['timestamp'] as String),
      bytesReclaimed: json['bytesReclaimed'] as int,
      targetsDeleted: json['targetsDeleted'] as int,
      targetsSkipped: json['targetsSkipped'] as int,
      wasDryRun: json['wasDryRun'] as bool,
    );
  }
}
