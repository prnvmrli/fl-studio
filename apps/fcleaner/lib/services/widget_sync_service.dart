import 'dart:convert';

import 'package:fclean/fclean.dart';
import 'package:flutter/services.dart';

/// Handles synchronization between the FCleaner Flutter application and the
/// native macOS WidgetKit extension (`FCleanerWidget`).
class WidgetSyncService {
  WidgetSyncService._();

  static final WidgetSyncService instance = WidgetSyncService._();

  static const MethodChannel _channel = MethodChannel('dev.fcleaner/widget');

  void Function(int tabIndex)? onNavigate;

  /// Initialize deep link listeners and tab navigation.
  void initialize({void Function(int tabIndex)? navigationHandler}) {
    onNavigate = navigationHandler;
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'onDeepLink') {
      final urlStr = call.arguments as String?;
      if (urlStr != null) {
        _handleDeepLink(urlStr);
      }
    }
  }

  void _handleDeepLink(String urlStr) {
    final uri = Uri.tryParse(urlStr);
    if (uri == null) return;

    // Handles fcleaner://scan, fcleaner://doctor, fcleaner://dashboard, etc.
    final target = uri.host.isNotEmpty ? uri.host : uri.path.replaceAll('/', '');
    switch (target) {
      case 'scan':
      case 'clean':
        onNavigate?.call(1);
        break;
      case 'analytics':
        onNavigate?.call(2);
        break;
      case 'doctor':
        onNavigate?.call(3);
        break;
      case 'settings':
        onNavigate?.call(4);
        break;
      case 'dashboard':
      default:
        onNavigate?.call(0);
        break;
    }
  }

  /// Sync detected system cache folders (Xcode DerivedData, Gradle, Pub Cache, etc.)
  Future<void> syncCacheEntries(List<ScanEntry> cacheEntries) async {
    final caches = <Map<String, dynamic>>[];
    int totalBytes = 0;

    for (final entry in cacheEntries) {
      totalBytes += entry.bytes;
      final (name, icon, colorHex) = _metadataForPath(entry.path);
      caches.add({
        'name': name,
        'bytes': entry.bytes,
        'iconName': icon,
        'colorHex': colorHex,
      });
    }

    final payload = {
      'totalBytes': totalBytes,
      'lastScanTime': DateTime.now().toUtc().toIso8601String(),
      'itemCount': cacheEntries.length,
      'caches': caches,
      'statusMessage': totalBytes > 0
          ? '${formatBytes(totalBytes)} Reclaimable'
          : 'Caches Clean',
    };

    await _dispatchUpdate(payload);
  }

  /// Sync results of a scan of Flutter projects or user directories.
  Future<void> syncScanEntries(List<ScanEntry> entries) async {
    final kindTotals = <ScanEntryKind, int>{};
    for (final e in entries) {
      kindTotals[e.kind] = (kindTotals[e.kind] ?? 0) + e.bytes;
    }

    final caches = <Map<String, dynamic>>[];
    int totalBytes = 0;

    kindTotals.forEach((kind, bytes) {
      if (bytes <= 0) return;
      totalBytes += bytes;
      final (name, icon, colorHex) = _metadataForKind(kind);
      caches.add({
        'name': name,
        'bytes': bytes,
        'iconName': icon,
        'colorHex': colorHex,
      });
    });

    final payload = {
      'totalBytes': totalBytes,
      'lastScanTime': DateTime.now().toUtc().toIso8601String(),
      'itemCount': entries.length,
      'caches': caches,
      'statusMessage': totalBytes > 0
          ? '${formatBytes(totalBytes)} Reclaimable'
          : 'Workspace Clean',
    };

    await _dispatchUpdate(payload);
  }

  /// Update widget state after a cleanup run.
  Future<void> syncAfterClean(int reclaimedBytes) async {
    final payload = {
      'totalBytes': 0,
      'lastScanTime': DateTime.now().toUtc().toIso8601String(),
      'itemCount': 0,
      'caches': <Map<String, dynamic>>[],
      'statusMessage': reclaimedBytes > 0
          ? 'Reclaimed ${formatBytes(reclaimedBytes)}!'
          : 'Caches Clean',
    };

    await _dispatchUpdate(payload);
  }

  Future<void> _dispatchUpdate(Map<String, dynamic> payload) async {
    try {
      await _channel.invokeMethod('updateWidgetData', {'json': jsonEncode(payload)});
    } catch (_) {
      // Ignored if channel is unavailable
    }
  }

  (String, String, String) _metadataForPath(String path) {
    final lower = path.toLowerCase();
    return switch (true) {
      _ when lower.contains('deriveddata') => ('DerivedData', 'hammer.fill', '00E5FF'),
      _ when lower.contains('.pub-cache') => ('Pub Cache', 'archivebox.fill', '00BFA5'),
      _ when lower.contains('gradle') => ('Gradle Cache', 'shippingbox.fill', '7C4DFF'),
      _ when lower.contains('cocoapods') => ('CocoaPods', 'cube.box.fill', 'FFAB00'),
      _ when lower.contains('android') => ('Android Cache', 'gearshape.2.fill', '00E676'),
      _ => ('Cache', 'folder.fill', '00BFA5'),
    };
  }

  (String, String, String) _metadataForKind(ScanEntryKind kind) {
    return switch (kind) {
      ScanEntryKind.folder => ('Build Folders', 'shippingbox.fill', '00E5FF'),
      ScanEntryKind.cache => ('Developer Caches', 'archivebox.fill', '00BFA5'),
      ScanEntryKind.archive => ('App Archives', 'gift.fill', 'FFAB00'),
      ScanEntryKind.flutterProject => ('Flutter Projects', 'hammer.fill', '7C4DFF'),
    };
  }
}
