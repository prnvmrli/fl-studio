import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/scan_result.dart';
import '../services/scanner_service.dart';
import '../utils/byte_format.dart';
import '../utils/exceptions.dart';
import 'base_command.dart';

class ScanCommand extends FCleanCommand {
  ScanCommand(super.context) {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        defaultsTo: Directory.current.path,
        help: 'Root directory to scan.',
      )
      ..addOption(
        'depth',
        defaultsTo: '6',
        help: 'Maximum recursive scan depth.',
      );
  }

  @override
  String get description => 'Scan for Flutter cleanup candidates.';

  @override
  String get name => 'scan';

  @override
  Future<int> runCommand() async {
    final root = p.normalize(p.absolute(argResults!['path'] as String));
    final depth = int.tryParse(argResults!['depth'] as String) ?? 6;
    final scanner = ScannerService(
      fileSystem: context.fileSystem,
      platform: context.platform,
    );

    final result = await context.terminal.withSpinner(
      'Scanning $root',
      () => scanner.scan(roots: [root], maxDepth: depth),
    );

    _printEntries(result.entries.take(20).toList());
    logger.info(
      'Total detected: ${formatBytes(result.totalBytes)} across ${result.entries.length} entries.',
    );
    return CleanerExitCode.success.code;
  }

  void _printEntries(List<ScanEntry> entries) {
    if (entries.isEmpty) {
      logger.info('No cleanup candidates found.');
      return;
    }
    for (final entry in entries) {
      logger.info(
        '${formatBytes(entry.bytes).padLeft(10)}  ${entry.kind.name.padRight(14)}  ${entry.path}',
      );
    }
  }
}
