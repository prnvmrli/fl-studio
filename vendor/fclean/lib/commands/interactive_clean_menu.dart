import 'dart:io';

import 'package:path/path.dart' as p;

import '../cleaners/android_cleaner.dart';
import '../cleaners/apple_cleaner.dart';
import '../cleaners/cleaner.dart';
import '../cleaners/flutter_project_cleaner.dart';
import '../models/cleanup_result.dart';
import '../models/cleanup_target.dart';
import '../services/cleaning_service.dart';
import '../services/scanner_service.dart';
import '../utils/byte_format.dart';
import '../utils/exceptions.dart';
import 'context.dart';

class InteractiveCleanMenu {
  InteractiveCleanMenu({required this.context, required bool dryRun})
      : _dryRun = dryRun;

  final CommandContext context;
  bool _dryRun;
  var _totalReclaimed = 0;

  Future<int> run() async {
    if (!context.terminal.isInteractive) {
      context.logger.warn(
        'Interactive mode requires a terminal. Use --include for automation.',
        tag: 'CLEAN',
      );
      return CleanerExitCode.usage.code;
    }

    final scanPath = _chooseScanDirectory();
    context.logger.info('Scanning directory: $scanPath');

    while (true) {
      _showMenu();
      final choice = context.terminal
          .prompt('Choose an option:', defaultValue: '0')
          .trim();

      switch (choice) {
        case '1':
          await _cleanTargets(
            'Cleaning Flutter build folders',
            () => _flutterBuildTargets(scanPath),
          );
        case '2':
          await _runFlutterClean(scanPath);
        case '3':
          await _cleanTargets('Cleaning Gradle cache', _gradleTargets);
        case '4':
          await _cleanTargets(
            'Cleaning CocoaPods',
            () => _cocoaPodsTargets(scanPath),
          );
        case '5':
          await _cleanTargets('Cleaning Xcode DerivedData', _xcodeTargets);
        case '6':
          await _cleanTargets(
            'Cleaning Android build cache',
            _androidBuildCacheTargets,
          );
        case '7':
          await _runCommand('Cleaning unavailable iOS simulators', [
            'xcrun',
            'simctl',
            'delete',
            'unavailable',
          ]);
        case '8':
          await _runCommand('Cleaning Homebrew cache', [
            'brew',
            'cleanup',
            '-s',
          ]);
        case '9':
          await _cleanTargets('Emptying Trash', _trashTargets);
        case '10':
          await _cleanTargets('Cleaning temporary files', _temporaryTargets);
        case '11':
          await _runCommand('Running flutter pub cache gc', [
            'flutter',
            'pub',
            'cache',
            'gc',
          ]);
        case '12':
          await _fullCleanup(scanPath);
        case '13':
          await _showLargestFolders(scanPath);
        case '14':
          _dryRun = !_dryRun;
          context.logger.warn(
            'Dry run mode ${_dryRun ? 'enabled' : 'disabled'}',
            tag: 'CLEAN',
          );
        case '0':
          _showReport();
          context.logger.success('Exiting cleaner');
          return CleanerExitCode.success.code;
        default:
          context.logger.err('Invalid option');
      }
    }
  }

  String _chooseScanDirectory() {
    final current = Directory.current.path;
    final choice = context.terminal.chooseOne(
      'Select scan directory',
      choices: [
        'Current directory ($current)',
        'Custom directory',
        'Whole system',
      ],
    );

    if (choice.startsWith('Current directory')) {
      return p.normalize(p.absolute(current));
    }
    if (choice == 'Whole system') {
      context.logger.warn(
        'Whole system scan enabled. Protected folders will be skipped.',
        tag: 'SCAN',
      );
      return p.rootPrefix(current).isEmpty ? '/' : p.rootPrefix(current);
    }

    final custom = context.terminal
        .prompt('Enter custom directory path:', defaultValue: current)
        .trim();
    return p.normalize(p.absolute(custom.isEmpty ? current : custom));
  }

  Future<void> _cleanTargets(
    String message,
    Future<List<CleanupTarget>> Function() discover,
  ) async {
    final targets = await context.terminal.withSpinner(message, discover);
    if (targets.isEmpty) {
      context.logger.info('No matching cleanup targets found.');
      return;
    }

    for (final target in targets) {
      final size = await context.fileSystem.sizeOf(target.path);
      context.logger.info('  ${target.label}: ${formatBytes(size)}');
      context.logger.detail('    ${target.path}');
    }

    if (!_dryRun &&
        !context.terminal.confirm(
          'Clean ${targets.length} target(s)?',
          defaultValue: false,
        )) {
      context.logger.warn('Cleanup skipped.', tag: 'CLEAN');
      return;
    }

    final service = CleaningService(
      cleaners: const [],
      targetCleaner: TargetCleaner(
        fileSystem: context.fileSystem,
        process: context.process,
      ),
    );
    final summary = await service.cleanTargets(targets, dryRun: _dryRun);
    _totalReclaimed += summary.reclaimedBytes;
    _printSummary(summary);
  }

  Future<List<CleanupTarget>> _flutterBuildTargets(String scanPath) async {
    final cleaner = FlutterProjectCleaner(
      root: scanPath,
      fileSystem: context.fileSystem,
    );
    return cleaner.discover();
  }

  Future<List<CleanupTarget>> _gradleTargets() async {
    final targets = <CleanupTarget>[];
    final home = context.platform.homeDirectory;
    final gradleCache = context.platform.androidGradleCache;
    if (gradleCache != null) {
      targets.add(
        CleanupTarget(
          id: 'gradle:caches',
          label: 'Gradle caches',
          path: gradleCache,
          category: CleanupCategory.android,
        ),
      );
    }
    if (home != null) {
      targets.add(
        CleanupTarget(
          id: 'gradle:daemon',
          label: 'Gradle daemon',
          path: p.join(home, '.gradle', 'daemon'),
          category: CleanupCategory.android,
        ),
      );
    }
    return targets;
  }

  Future<List<CleanupTarget>> _cocoaPodsTargets(String scanPath) async {
    final config = await context.config.load();
    final global = await AppleCleaner(
      platform: context.platform,
      config: config,
    ).discover();
    final pods = await context.fileSystem.findNamedDirectories(
      root: scanPath,
      names: {'Pods'},
      maxDepth: 8,
    );
    final locks = await context.fileSystem.findNamedFiles(
      root: scanPath,
      names: {'Podfile.lock'},
      maxDepth: 8,
    );
    final home = context.platform.homeDirectory;

    return [
      ...global.where((target) => target.id.contains('cocoapods')),
      if (home != null)
        CleanupTarget(
          id: 'cocoapods:repo',
          label: 'CocoaPods repo cache',
          path: p.join(home, '.cocoapods'),
          category: CleanupCategory.apple,
        ),
      ...pods.map(
        (path) => CleanupTarget(
          id: 'cocoapods:pods:$path',
          label: 'Pods folder',
          path: path,
          category: CleanupCategory.apple,
        ),
      ),
      ...locks.map(
        (path) => CleanupTarget(
          id: 'cocoapods:lock:$path',
          label: 'Podfile.lock',
          path: path,
          category: CleanupCategory.apple,
        ),
      ),
    ];
  }

  Future<List<CleanupTarget>> _xcodeTargets() async {
    final config = await context.config.load();
    final targets = await AppleCleaner(
      platform: context.platform,
      config: config,
    ).discover();
    return targets
        .where((target) => target.id.contains('derived-data'))
        .toList();
  }

  Future<List<CleanupTarget>> _androidBuildCacheTargets() async {
    final targets = await AndroidCleaner(
      platform: context.platform,
      config: await context.config.load(),
    ).discover();
    final home = context.platform.homeDirectory;
    return [
      ...targets.where((target) => target.id.contains('build-cache')),
      if (home != null && context.platform.isMacOS)
        CleanupTarget(
          id: 'android:mac-build-cache',
          label: 'Android macOS build cache',
          path: p.join(home, 'Library', 'Android', 'build-cache'),
          category: CleanupCategory.android,
        ),
    ];
  }

  Future<List<CleanupTarget>> _trashTargets() async {
    final trash = context.platform.trashDirectory;
    if (trash == null) return const [];
    return [
      CleanupTarget(
        id: 'system:trash',
        label: context.platform.isWindows ? 'Recycle bin' : 'Trash',
        path: trash,
        category: CleanupCategory.system,
        contentsOnly: true,
      ),
    ];
  }

  Future<List<CleanupTarget>> _temporaryTargets() async {
    final targets = <CleanupTarget>[
      CleanupTarget(
        id: 'system:temp',
        label: 'Temporary files',
        path: context.platform.tempDirectory,
        category: CleanupCategory.system,
        contentsOnly: true,
      ),
    ];
    if (context.platform.isMacOS) {
      targets.add(
        const CleanupTarget(
          id: 'system:private-var-tmp',
          label: '/private/var/tmp contents',
          path: '/private/var/tmp',
          category: CleanupCategory.system,
          contentsOnly: true,
        ),
      );
    }
    return targets;
  }

  Future<void> _runFlutterClean(String scanPath) async {
    final pubspecs = await context.fileSystem.findNamedFiles(
      root: scanPath,
      names: {'pubspec.yaml'},
      maxDepth: 8,
    );
    if (pubspecs.isEmpty) {
      context.logger.info('No Flutter projects found.');
      return;
    }

    for (final pubspec in pubspecs) {
      final project = p.dirname(pubspec);
      context.logger.info(
        _dryRun
            ? '[DRY RUN] Would run flutter clean in $project'
            : 'Cleaning project: $project',
      );
      if (_dryRun) continue;
      final result = await context.terminal.withSpinner(
        'Running flutter clean',
        () => context.process.run(
            'flutter',
            [
              'clean',
            ],
            workingDirectory: project),
      );
      if (result.exitCode != 0) {
        context.logger.warn('flutter clean failed in $project', tag: 'FLUTTER');
      }
    }
  }

  Future<void> _runCommand(String message, List<String> command) async {
    if (_dryRun) {
      context.logger.info('[DRY RUN] Would run: ${command.join(' ')}');
      return;
    }
    if (!context.terminal.confirm('$message?', defaultValue: false)) return;
    final executable = command.first;
    if (!await context.process.isAvailable(executable)) {
      context.logger.warn(
        '$executable not installed or not on PATH',
        tag: 'CLEAN',
      );
      return;
    }
    final result = await context.terminal.withSpinner(
      message,
      () => context.process.run(executable, command.skip(1).toList()),
    );
    if (result.exitCode == 0) {
      context.logger.success('$message completed.');
    } else {
      context.logger.err('$message failed: ${result.stderr}'.trim());
    }
  }

  Future<void> _fullCleanup(String scanPath) async {
    await _cleanTargets(
      'Cleaning Flutter build folders',
      () => _flutterBuildTargets(scanPath),
    );
    await _runFlutterClean(scanPath);
    await _cleanTargets('Cleaning Gradle cache', _gradleTargets);
    await _cleanTargets(
      'Cleaning CocoaPods',
      () => _cocoaPodsTargets(scanPath),
    );
    await _cleanTargets('Cleaning Xcode DerivedData', _xcodeTargets);
    await _cleanTargets(
      'Cleaning Android build cache',
      _androidBuildCacheTargets,
    );
    await _runCommand('Cleaning unavailable iOS simulators', [
      'xcrun',
      'simctl',
      'delete',
      'unavailable',
    ]);
    await _runCommand('Cleaning Homebrew cache', ['brew', 'cleanup', '-s']);
    await _cleanTargets('Emptying Trash', _trashTargets);
    await _cleanTargets('Cleaning temporary files', _temporaryTargets);
    await _runCommand('Running flutter pub cache gc', [
      'flutter',
      'pub',
      'cache',
      'gc',
    ]);
    _showReport();
  }

  Future<void> _showLargestFolders(String scanPath) async {
    final scanner = ScannerService(
      fileSystem: context.fileSystem,
      platform: context.platform,
    );
    final result = await context.terminal.withSpinner(
      'Finding largest folders',
      () => scanner.scan(roots: [scanPath], maxDepth: 8),
    );
    for (final entry in result.entries.take(20)) {
      context.logger.info(
        '${formatBytes(entry.bytes).padLeft(10)}  ${entry.kind.name.padRight(14)}  ${entry.path}',
      );
    }
  }

  void _showMenu() {
    context.logger.info('');
    context.logger.info('========================================');
    context.logger.info(' fclean');
    context.logger.info('========================================');
    context.logger.info('1. Clean Flutter build folders');
    context.logger.info('2. Run flutter clean on projects');
    context.logger.info('3. Clean Gradle cache');
    context.logger.info('4. Clean CocoaPods');
    context.logger.info('5. Clean Xcode DerivedData');
    context.logger.info('6. Clean Android build cache');
    context.logger.info('7. Clean iOS simulators');
    context.logger.info('8. Clean Homebrew cache');
    context.logger.info('9. Empty Trash');
    context.logger.info('10. Clean temporary files');
    context.logger.info('11. Run flutter pub cache gc');
    context.logger.info('12. Full cleanup');
    context.logger.info('13. Show largest folders');
    context.logger.info('14. Toggle dry run mode (${_dryRun ? 'on' : 'off'})');
    context.logger.info('0. Exit');
  }

  void _printSummary(CleanupSummary summary) {
    final label = _dryRun ? 'Reclaimable' : 'Reclaimed';
    context.logger.success(
      '$label space: ${formatBytes(summary.reclaimedBytes)}',
    );
    context.logger.info(
      'Targets processed: ${summary.deletedCount}, skipped: ${summary.skippedCount}',
    );
  }

  void _showReport() {
    context.logger.info('');
    context.logger.info('=======================================');
    context.logger.info('Cleanup Completed');
    context.logger.info('=======================================');
    context.logger.success(
      'Approx space reclaimed: ${formatBytes(_totalReclaimed)}',
    );
  }
}
