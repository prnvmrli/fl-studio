import 'package:fclean/fclean.dart';
import 'package:flutter/foundation.dart';

import '../services/widget_sync_service.dart';

enum CleanState { idle, discovering, ready, cleaning, done, error }

class CleanProvider extends ChangeNotifier {
  CleanProvider();

  final _fileSystem = const FileSystemService();
  final _platform = const PlatformService();
  final _process = const ProcessService();

  late final _targetCleaner = TargetCleaner(
    fileSystem: _fileSystem,
    process: _process,
  );

  AppConfig _config = AppConfig.defaults;
  AppConfig get config => _config;
  set config(AppConfig value) {
    _config = value;
    notifyListeners();
  }

  CleanState _state = CleanState.idle;
  CleanState get state => _state;

  List<CleanupTarget> _targets = [];
  List<CleanupTarget> get targets => List.unmodifiable(_targets);

  final Set<String> _selectedIds = {};
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);

  List<CleanupTarget> get selectedTargets =>
      _targets.where((t) => _selectedIds.contains(t.id)).toList();

  bool _dryRun = false;
  bool get dryRun => _dryRun;
  set dryRun(bool value) {
    _dryRun = value;
    notifyListeners();
  }

  CleanupSummary? _summary;
  CleanupSummary? get summary => _summary;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Current target being cleaned
  String? _currentTargetLabel;
  String? get currentTargetLabel => _currentTargetLabel;
  int _cleanedCount = 0;
  int get cleanedCount => _cleanedCount;

  // ── Target sizes (computed async) ────────────────────────────────
  final Map<String, int> _targetSizes = {};
  Map<String, int> get targetSizes => Map.unmodifiable(_targetSizes);

  int get totalSelectedBytes {
    return selectedTargets.fold(0, (sum, t) => sum + (_targetSizes[t.id] ?? 0));
  }

  // ── Grouped helpers ──────────────────────────────────────────────
  Map<CleanupCategory, List<CleanupTarget>> get targetsByCategory {
    final map = <CleanupCategory, List<CleanupTarget>>{};
    for (final target in _targets) {
      map.putIfAbsent(target.category, () => []).add(target);
    }
    return map;
  }

  // ── Actions ──────────────────────────────────────────────────────
  Future<void> discoverTargets({String root = '.'}) async {
    _state = CleanState.discovering;
    _targets = [];
    _selectedIds.clear();
    _targetSizes.clear();
    _summary = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleaners = <Cleaner>[
        FlutterProjectCleaner(root: root, fileSystem: _fileSystem),
        AndroidCleaner(platform: _platform, config: _config),
        AppleCleaner(platform: _platform, config: _config),
        SystemCleaner(platform: _platform, config: _config),
      ];
      final service = CleaningService(
        cleaners: cleaners,
        targetCleaner: _targetCleaner,
      );

      _targets = await service.discoverTargets();

      // Compute sizes in parallel
      await Future.wait(
        _targets.map((t) async {
          if (_fileSystem.exists(t.path)) {
            _targetSizes[t.id] = await _fileSystem.sizeOf(t.path);
          } else {
            _targetSizes[t.id] = 0;
          }
        }),
      );

      _state = CleanState.ready;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = CleanState.error;
      notifyListeners();
    }
  }

  void toggleTarget(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds.addAll(_targets.map((t) => t.id));
    notifyListeners();
  }

  void deselectAll() {
    _selectedIds.clear();
    notifyListeners();
  }

  void selectCategory(CleanupCategory category) {
    for (final t in _targets.where((t) => t.category == category)) {
      _selectedIds.add(t.id);
    }
    notifyListeners();
  }

  Future<void> cleanSelected() async {
    if (_selectedIds.isEmpty) return;

    _state = CleanState.cleaning;
    _cleanedCount = 0;
    _currentTargetLabel = null;
    _summary = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = <CleanupResult>[];
      final selected = selectedTargets;

      for (final target in selected) {
        _currentTargetLabel = target.label;
        _cleanedCount = results.length;
        notifyListeners();

        results.add(await _targetCleaner.clean(target, dryRun: _dryRun));
      }

      _summary = CleanupSummary(results);
      _cleanedCount = results.length;
      _currentTargetLabel = null;
      _state = CleanState.done;
      WidgetSyncService.instance.syncAfterClean(_summary?.reclaimedBytes ?? 0);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = CleanState.error;
      notifyListeners();
    }
  }

  void reset() {
    _state = CleanState.idle;
    _targets = [];
    _selectedIds.clear();
    _targetSizes.clear();
    _summary = null;
    _errorMessage = null;
    _currentTargetLabel = null;
    _cleanedCount = 0;
    notifyListeners();
  }
}
