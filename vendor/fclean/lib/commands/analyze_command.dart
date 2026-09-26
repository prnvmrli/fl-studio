import 'dart:io';

import 'package:path/path.dart' as p;

import '../services/scanner_service.dart';
import '../utils/byte_format.dart';
import '../utils/exceptions.dart';
import 'base_command.dart';

class AnalyzeCommand extends FCleanCommand {
  AnalyzeCommand(super.context) {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        defaultsTo: Directory.current.path,
        help: 'Root directory to analyze.',
      )
      ..addOption(
        'top',
        defaultsTo: '10',
        help: 'Number of largest entries to show.',
      );
  }

  @override
  String get description =>
      'Analyze largest folders, app archives, caches, and Flutter projects.';

  @override
  String get name => 'analyze';

  @override
  Future<int> runCommand() async {
    final root = p.normalize(p.absolute(argResults!['path'] as String));
    final top = int.tryParse(argResults!['top'] as String) ?? 10;
    final scanner = ScannerService(
      fileSystem: context.fileSystem,
      platform: context.platform,
    );

    final scan = await context.terminal.withSpinner(
      'Analyzing project footprint',
      () => scanner.scan(roots: [root]),
    );
    final caches = await scanner.cacheEntries();

    logger.info('Largest entries:');
    for (final entry in scan.entries.take(top)) {
      logger.info(
        '${formatBytes(entry.bytes).padLeft(10)}  ${entry.kind.name.padRight(14)}  ${entry.path}',
      );
    }

    logger.info('');
    logger.info('Cache report:');
    for (final entry in caches) {
      logger.info('${formatBytes(entry.bytes).padLeft(10)}  ${entry.path}');
    }

    logger.success('Total project candidates: ${formatBytes(scan.totalBytes)}');
    return CleanerExitCode.success.code;
  }
}
