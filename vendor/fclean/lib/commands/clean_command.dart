import 'dart:io';

import 'package:path/path.dart' as p;

import '../cleaners/android_cleaner.dart';
import '../cleaners/apple_cleaner.dart';
import '../cleaners/cleaner.dart';
import '../cleaners/flutter_project_cleaner.dart';
import '../cleaners/system_cleaner.dart';
import '../models/cleanup_result.dart';
import '../models/cleanup_target.dart';
import '../services/cleaning_service.dart';
import '../utils/byte_format.dart';
import '../utils/exceptions.dart';
import 'base_command.dart';
import 'interactive_clean_menu.dart';

class CleanCommand extends FCleanCommand {
  CleanCommand(super.context) {
    argParser
      ..addFlag(
        'dry-run',
        help: 'Preview what would be removed.',
        negatable: false,
      )
      ..addFlag(
        'yes',
        abbr: 'y',
        help: 'Skip confirmation prompts.',
        negatable: false,
      )
      ..addFlag(
        'interactive',
        abbr: 'i',
        help: 'Use an interactive menu similar to the shell-script workflow.',
        negatable: false,
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Flutter project or workspace to clean.',
        defaultsTo: Directory.current.path,
      )
      ..addMultiOption(
        'include',
        allowed: ['flutter', 'android', 'apple', 'system'],
        help: 'Limit cleanup to one or more categories.',
      );
  }

  @override
  String get description =>
      'Clean Flutter build folders and development caches.';

  @override
  String get name => 'clean';

  @override
  Future<int> runCommand() async {
    final dryRun = argResults!['dry-run'] == true;
    final assumeYes = argResults!['yes'] == true;
    final interactive = argResults!['interactive'] == true;
    if (interactive) {
      final menu = InteractiveCleanMenu(context: context, dryRun: dryRun);
      return menu.run();
    }

    final root = p.normalize(p.absolute(argResults!['path'] as String));
    final include = (argResults!['include'] as List<String>).toSet();
    final config = await context.config.load();
    final service = CleaningService(
      cleaners: [
        FlutterProjectCleaner(root: root, fileSystem: context.fileSystem),
        if (include.isEmpty || include.contains('android'))
          AndroidCleaner(platform: context.platform, config: config),
        if (include.isEmpty || include.contains('apple'))
          AppleCleaner(platform: context.platform, config: config),
        if (include.isEmpty || include.contains('system'))
          SystemCleaner(platform: context.platform, config: config),
      ],
      targetCleaner: TargetCleaner(
        fileSystem: context.fileSystem,
        process: context.process,
      ),
    );

    var targets = await context.terminal.withSpinner(
      'Discovering cleanup targets',
      service.discoverTargets,
    );
    targets = _filterTargets(targets, include);

    if (targets.isEmpty) {
      logger.info('No cleanup targets found.');
      return CleanerExitCode.success.code;
    }

    logger.info(dryRun ? 'Dry run cleanup plan:' : 'Cleanup plan:');
    for (final target in targets) {
      final size = await context.fileSystem.sizeOf(target.path);
      logger.info('  ${target.label}: ${formatBytes(size)}');
      logger.detail('    ${target.path}');
    }

    if (!dryRun &&
        !context.terminal.confirm(
          'Delete ${targets.length} cleanup targets?',
          defaultValue: false,
          assumeYes: assumeYes,
        )) {
      logger.warn('Cleanup cancelled.', tag: 'CLEAN');
      return CleanerExitCode.success.code;
    }

    final summary = await context.terminal.withSpinner(
      dryRun ? 'Calculating reclaimable space' : 'Cleaning selected targets',
      () => service.cleanTargets(targets, dryRun: dryRun),
    );

    _printSummary(summary, dryRun: dryRun);
    return CleanerExitCode.success.code;
  }

  List<CleanupTarget> _filterTargets(
    List<CleanupTarget> targets,
    Set<String> include,
  ) {
    if (include.isEmpty) return targets;
    return targets
        .where((target) => include.contains(target.category.name))
        .toList();
  }

  void _printSummary(CleanupSummary summary, {required bool dryRun}) {
    final label = dryRun ? 'Reclaimable' : 'Reclaimed';
    logger.success('$label space: ${formatBytes(summary.reclaimedBytes)}');
    logger.info(
      'Targets processed: ${summary.deletedCount}, skipped: ${summary.skippedCount}',
    );
    for (final result in summary.results.where(
      (item) => !item.deleted && item.skippedReason != 'missing',
    )) {
      logger.warn(
        'Skipped ${result.target.label}: ${result.skippedReason}',
        tag: 'SKIP',
      );
    }
  }
}
