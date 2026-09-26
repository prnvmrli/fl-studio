import 'package:path/path.dart' as p;

import '../models/cleanup_target.dart';
import '../services/file_system_service.dart';
import 'cleaner.dart';

class FlutterProjectCleaner extends Cleaner {
  const FlutterProjectCleaner({
    required this.root,
    required FileSystemService fileSystem,
  }) : _fileSystem = fileSystem;

  final String root;
  final FileSystemService _fileSystem;

  @override
  String get name => 'Flutter project';

  @override
  Future<List<CleanupTarget>> discover() async {
    final paths = {
      p.join(root, 'build'),
      p.join(root, '.dart_tool'),
      p.join(root, '.symlinks'),
      ...await _fileSystem.findNamedDirectories(
        root: root,
        names: {'build'},
        maxDepth: 5,
      ),
    };

    return paths.map((path) {
      return CleanupTarget(
        id: 'flutter:${p.basename(path)}:$path',
        label: 'Flutter ${p.basename(path)}',
        path: path,
        category: CleanupCategory.flutter,
      );
    }).toList();
  }
}
