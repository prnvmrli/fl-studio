import 'dart:io';

import '../services/process_service.dart';
import '../services/scanner_service.dart';
import '../utils/byte_format.dart';
import '../utils/exceptions.dart';
import 'base_command.dart';

class CacheCommand extends FCleanCommand {
  CacheCommand(super.context) {
    addSubcommand(CacheGcCommand(context));
  }

  @override
  String get description => 'Manage Flutter and development caches.';

  @override
  String get name => 'cache';

  @override
  Future<int> runCommand() async {
    printUsage();
    return CleanerExitCode.success.code;
  }
}

class CacheGcCommand extends FCleanCommand {
  CacheGcCommand(super.context) {
    argParser
      ..addFlag(
        'dry-run',
        help: 'Show cache sizes without running garbage collection.',
        negatable: false,
      )
      ..addFlag(
        'yes',
        abbr: 'y',
        help: 'Skip confirmation prompts.',
        negatable: false,
      );
  }

  @override
  String get description =>
      'Run `flutter pub cache gc` and report cache sizes.';

  @override
  String get name => 'gc';

  @override
  Future<int> runCommand() async {
    final dryRun = argResults!['dry-run'] == true;
    final assumeYes = argResults!['yes'] == true;
    final scanner = ScannerService(
      fileSystem: context.fileSystem,
      platform: context.platform,
    );
    final caches = await scanner.cacheEntries();

    for (final entry in caches) {
      logger.info('${formatBytes(entry.bytes).padLeft(10)}  ${entry.path}');
    }

    if (dryRun) return CleanerExitCode.success.code;
    if (!context.terminal.confirm(
      'Run flutter pub cache gc?',
      defaultValue: false,
      assumeYes: assumeYes,
    )) {
      logger.warn('Cache GC cancelled.', tag: 'CACHE');
      return CleanerExitCode.success.code;
    }

    final result = await _runFlutterPubCacheGc(context.process);
    if (result.exitCode != 0) {
      logger.err('${result.stderr}'.trim());
      return result.exitCode;
    }
    logger.success(
      '${result.stdout}'.trim().isEmpty
          ? 'Flutter pub cache GC complete.'
          : '${result.stdout}'.trim(),
    );
    return CleanerExitCode.success.code;
  }

  Future<ProcessResult> _runFlutterPubCacheGc(ProcessService process) {
    return context.terminal.withSpinner(
      'Running flutter pub cache gc',
      () => process.run('flutter', ['pub', 'cache', 'gc']),
    );
  }
}
