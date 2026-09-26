import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/scan_result.dart';
import 'file_system_service.dart';
import 'platform_service.dart';

class ScannerService {
  const ScannerService({
    required FileSystemService fileSystem,
    required PlatformService platform,
  })  : _fileSystem = fileSystem,
        _platform = platform;

  final FileSystemService _fileSystem;
  final PlatformService _platform;

  Future<ScanResult> scan({
    required List<String> roots,
    int maxDepth = 6,
  }) async {
    final entries = <ScanEntry>[];
    await for (final progress in scanStream(roots: roots, maxDepth: maxDepth)) {
      entries.addAll(progress.newEntries);
    }
    entries.sort((a, b) => b.bytes.compareTo(a.bytes));
    return ScanResult(entries: entries, scannedRoots: roots);
  }

  Stream<ScanProgress> scanStream({
    required List<String> roots,
    int maxDepth = 6,
  }) async* {
    final allEntries = <ScanEntry>[];
    for (final root in roots) {
      await for (final entry in _scanRootStream(root, maxDepth: maxDepth)) {
        allEntries.add(entry);
        yield ScanProgress(
          currentPath: entry.path,
          newEntries: [entry],
          totalEntries: allEntries.length,
          totalBytes: allEntries.fold(0, (sum, e) => sum + e.bytes),
        );
      }
    }
  }

  Stream<ScanEntry> _scanRootStream(
    String root, {
    required int maxDepth,
  }) async* {
    if (!Directory(root).existsSync()) return;

    final queue = <(Directory, int)>[(Directory(root), 0)];

    while (queue.isNotEmpty) {
      final (directory, depth) = queue.removeAt(0);
      if (depth > maxDepth) continue;

      List<FileSystemEntity> children;
      try {
        children = await directory.list(followLinks: false).toList();
      } on FileSystemException {
        continue;
      }

      final hasPubspec = children.any(
        (child) => child is File && p.basename(child.path) == 'pubspec.yaml',
      );
      final hasFlutterDirs = children.any((child) {
        if (child is! Directory) return false;
        return p.basename(child.path) == 'android' ||
            p.basename(child.path) == 'ios';
      });

      if (hasPubspec && hasFlutterDirs) {
        yield ScanEntry(
          path: directory.path,
          bytes: await _fileSystem.sizeOf(directory.path),
          kind: ScanEntryKind.flutterProject,
        );
      }

      for (final child in children) {
        final basename = p.basename(child.path);
        if (child is File && _isLargeAppArchive(child.path)) {
          yield ScanEntry(
            path: child.path,
            bytes: await child.length(),
            kind: ScanEntryKind.archive,
          );
        }
        if (child is! Directory) continue;
        if (_shouldSkipDirectory(basename)) continue;

        if (_isInterestingFolder(basename)) {
          yield ScanEntry(
            path: child.path,
            bytes: await _fileSystem.sizeOf(child.path),
            kind: _kindForFolder(basename),
          );
          continue;
        }
        queue.add((child, depth + 1));
      }
    }
  }

  Future<List<ScanEntry>> cacheEntries() async {
    final roots = <String?>[
      _platform.pubCacheDirectory,
      _platform.androidGradleCache,
      _platform.androidBuildCache,
      _platform.xcodeDerivedData,
      _platform.cocoaPodsCache,
    ];
    final entries = <ScanEntry>[];
    for (final root in roots.whereType<String>()) {
      if (Directory(root).existsSync()) {
        entries.add(
          ScanEntry(
            path: root,
            bytes: await _fileSystem.sizeOf(root),
            kind: ScanEntryKind.cache,
          ),
        );
      }
    }
    entries.sort((a, b) => b.bytes.compareTo(a.bytes));
    return entries;
  }

  bool _isLargeAppArchive(String path) {
    final ext = p.extension(path).toLowerCase();
    return ext == '.apk' || ext == '.aab' || ext == '.ipa';
  }

  bool _isInterestingFolder(String name) {
    return name == 'build' ||
        name == '.dart_tool' ||
        name == 'DerivedData' ||
        name == 'Pods';
  }

  ScanEntryKind _kindForFolder(String name) {
    return name == 'build' || name == '.dart_tool'
        ? ScanEntryKind.folder
        : ScanEntryKind.cache;
  }

  bool _shouldSkipDirectory(String name) {
    return name == '.git' ||
        name == '.idea' ||
        name == '.vscode' ||
        name == 'node_modules';
  }
}
