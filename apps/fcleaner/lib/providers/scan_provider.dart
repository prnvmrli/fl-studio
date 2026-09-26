import 'dart:async';

import 'package:fclean/fclean.dart';
import 'package:flutter/foundation.dart';

import '../services/widget_sync_service.dart';

enum ScanState { idle, scanning, done, error }

class ScanProvider extends ChangeNotifier {
  ScanProvider();

  final _fileSystem = const FileSystemService();
  final _platform = const PlatformService();

  late final _scanner = ScannerService(
    fileSystem: _fileSystem,
    platform: _platform,
  );

  ScanState _state = ScanState.idle;
  ScanState get state => _state;

  List<ScanEntry> _entries = [];
  List<ScanEntry> get entries => List.unmodifiable(_entries);

  String _currentPath = '';
  String get currentPath => _currentPath;

  int _totalBytes = 0;
  int get totalBytes => _totalBytes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<String> _scannedRoots = [];
  List<String> get scannedRoots => _scannedRoots;

  StreamSubscription<ScanProgress>? _scanSubscription;

  // ── Cache entries (Gradle, DerivedData, CocoaPods, etc.) ──────────
  List<ScanEntry> _cacheEntries = [];
  List<ScanEntry> get cacheEntries => List.unmodifiable(_cacheEntries);

  int get cacheTotalBytes => _cacheEntries.fold(0, (sum, e) => sum + e.bytes);

  // ── Grouped helpers ───────────────────────────────────────────────
  Map<ScanEntryKind, List<ScanEntry>> get entriesByKind {
    final map = <ScanEntryKind, List<ScanEntry>>{};
    for (final entry in _entries) {
      map.putIfAbsent(entry.kind, () => []).add(entry);
    }
    return map;
  }

  int bytesByKind(ScanEntryKind kind) {
    return _entries
        .where((e) => e.kind == kind)
        .fold(0, (sum, e) => sum + e.bytes);
  }

  // ── Actions ───────────────────────────────────────────────────────
  Future<void> scan(List<String> roots, {int maxDepth = 6}) async {
    _state = ScanState.scanning;
    _entries = [];
    _totalBytes = 0;
    _currentPath = '';
    _errorMessage = null;
    _scannedRoots = roots;
    notifyListeners();

    try {
      _scanSubscription = _scanner
          .scanStream(roots: roots, maxDepth: maxDepth)
          .listen(
            (progress) {
              _entries.addAll(progress.newEntries);
              _currentPath = progress.currentPath;
              _totalBytes = progress.totalBytes;
              notifyListeners();
            },
            onDone: () {
              _entries.sort((a, b) => b.bytes.compareTo(a.bytes));
              _state = ScanState.done;
              WidgetSyncService.instance.syncScanEntries(_entries);
              notifyListeners();
            },
            onError: (Object error) {
              _errorMessage = error.toString();
              _state = ScanState.error;
              notifyListeners();
            },
          );
    } catch (e) {
      _errorMessage = e.toString();
      _state = ScanState.error;
      notifyListeners();
    }
  }

  Future<void> scanCaches() async {
    try {
      _cacheEntries = await _scanner.cacheEntries();
      WidgetSyncService.instance.syncCacheEntries(_cacheEntries);
      notifyListeners();
    } catch (_) {
      // Cache scan failure is non-fatal.
    }
  }

  void cancelScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if (_state == ScanState.scanning) {
      _entries.sort((a, b) => b.bytes.compareTo(a.bytes));
      _state = ScanState.done;
      notifyListeners();
    }
  }

  void reset() {
    cancelScan();
    _state = ScanState.idle;
    _entries = [];
    _totalBytes = 0;
    _currentPath = '';
    _errorMessage = null;
    _scannedRoots = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}
