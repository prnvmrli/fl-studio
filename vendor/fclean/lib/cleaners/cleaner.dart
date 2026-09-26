import '../models/cleanup_result.dart';
import '../models/cleanup_target.dart';
import '../services/file_system_service.dart';
import '../services/process_service.dart';

abstract class Cleaner {
  const Cleaner();

  String get name;

  Future<List<CleanupTarget>> discover();
}

class TargetCleaner {
  const TargetCleaner({
    required FileSystemService fileSystem,
    required ProcessService process,
  })  : _fileSystem = fileSystem,
        _process = process;

  final FileSystemService _fileSystem;
  final ProcessService _process;

  Future<CleanupResult> clean(
    CleanupTarget target, {
    required bool dryRun,
  }) async {
    if (!_fileSystem.exists(target.path)) {
      if (target.command != null) {
        return _runCommand(target);
      }
      return CleanupResult(
        target: target,
        bytesReclaimed: 0,
        deleted: false,
        skippedReason: 'missing',
      );
    }

    if (target.contentsOnly) {
      return _cleanContents(target, dryRun: dryRun);
    }

    final size = await _fileSystem.sizeOf(target.path);
    final deleted = await _fileSystem.delete(target.path, dryRun: dryRun);
    return CleanupResult(
      target: target,
      bytesReclaimed: deleted ? size : 0,
      deleted: deleted,
      skippedReason: deleted ? null : 'protected',
    );
  }

  Future<CleanupResult> _runCommand(CleanupTarget target) async {
    final command = target.command!;
    final result = await _process.run(command.first, command.skip(1).toList());
    return CleanupResult(
      target: target,
      bytesReclaimed: 0,
      deleted: result.exitCode == 0,
      skippedReason: result.exitCode == 0 ? null : 'command failed',
    );
  }

  Future<CleanupResult> _cleanContents(
    CleanupTarget target, {
    required bool dryRun,
  }) async {
    final beforeSize = await _fileSystem.sizeOf(target.path);
    final deleted = await _fileSystem.deleteChildren(
      target.path,
      dryRun: dryRun,
    );
    final afterSize = dryRun ? 0 : await _fileSystem.sizeOf(target.path);
    final bytesReclaimed = dryRun
        ? beforeSize
        : beforeSize > afterSize
            ? beforeSize - afterSize
            : 0;
    return CleanupResult(
      target: target,
      bytesReclaimed: bytesReclaimed,
      deleted: deleted,
      skippedReason: deleted ? null : 'partially protected',
    );
  }
}
