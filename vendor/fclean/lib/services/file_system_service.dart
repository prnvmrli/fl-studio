import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../utils/path_safety.dart';

class FileSystemService {
  const FileSystemService();

  bool exists(String path) =>
      FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;

  Future<int> sizeOf(String path) async {
    final type = FileSystemEntity.typeSync(path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return 0;
    if (type == FileSystemEntityType.file) return File(path).lengthSync();
    if (type != FileSystemEntityType.directory) return 0;

    var total = 0;
    final directory = Directory(path);
    await for (final entity in directory
        .list(recursive: true, followLinks: false)
        .handleError((_) {})) {
      if (entity is File) {
        try {
          total += await entity.length();
        } on FileSystemException {
          // Files can vanish while scanning caches; ignore and continue.
        }
      }
    }
    return total;
  }

  Future<bool> delete(String path, {required bool dryRun}) async {
    if (isProtectedPath(path)) return false;
    if (!exists(path)) return false;
    if (dryRun) return true;

    final type = FileSystemEntity.typeSync(path, followLinks: false);
    try {
      if (type == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: true);
      } else {
        await File(path).delete();
      }
    } on FileSystemException {
      return false;
    }
    return true;
  }

  Future<bool> deleteChildren(String path, {required bool dryRun}) async {
    if (isProtectedPath(path) || !Directory(path).existsSync()) return false;
    if (dryRun) return true;

    List<FileSystemEntity> children;
    try {
      children = await Directory(path).list(followLinks: false).toList();
    } on FileSystemException {
      return false;
    }

    var allDeleted = true;
    for (final child in children) {
      final deleted = await delete(child.path, dryRun: false);
      if (!deleted && exists(child.path)) {
        allDeleted = false;
      }
    }
    return allDeleted;
  }

  Future<List<String>> findNamedDirectories({
    required String root,
    required Set<String> names,
    int maxDepth = 6,
    Set<String> protectedNames = const {
      '.git',
      '.idea',
      '.vscode',
      'node_modules',
      'Library',
      'Applications',
      'System',
      'Volumes',
      'private',
    },
  }) async {
    final results = <String>[];
    if (!Directory(root).existsSync()) return results;

    Future<void> walk(Directory directory, int depth) async {
      if (depth > maxDepth) return;
      List<FileSystemEntity> children;
      try {
        children = await directory.list(followLinks: false).toList();
      } on FileSystemException {
        return;
      }

      for (final child in children) {
        if (child is! Directory) continue;
        final basename = p.basename(child.path);
        if (names.contains(basename)) {
          results.add(child.path);
          continue;
        }
        if (protectedNames.contains(basename) ||
            basename.startsWith('.Trash')) {
          continue;
        }
        await walk(child, depth + 1);
      }
    }

    await walk(Directory(root), 0);
    return results;
  }

  Future<List<String>> findNamedFiles({
    required String root,
    required Set<String> names,
    int maxDepth = 6,
    Set<String> protectedNames = const {
      '.git',
      '.idea',
      '.vscode',
      'node_modules',
      'Library',
      'Applications',
      'System',
      'Volumes',
    },
  }) async {
    final results = <String>[];
    if (!Directory(root).existsSync()) return results;

    Future<void> walk(Directory directory, int depth) async {
      if (depth > maxDepth) return;
      List<FileSystemEntity> children;
      try {
        children = await directory.list(followLinks: false).toList();
      } on FileSystemException {
        return;
      }

      for (final child in children) {
        final basename = p.basename(child.path);
        if (child is File && names.contains(basename)) {
          results.add(child.path);
          continue;
        }
        if (child is Directory) {
          if (protectedNames.contains(basename) ||
              basename.startsWith('.Trash')) {
            continue;
          }
          await walk(child, depth + 1);
        }
      }
    }

    await walk(Directory(root), 0);
    return results;
  }
}
