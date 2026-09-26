import 'package:args/command_runner.dart';

import 'context.dart';
import '../utils/logger.dart';

abstract class FCleanCommand extends Command<int> {
  FCleanCommand(this.context) {
    argParser
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Show debug logging.',
        negatable: false,
      )
      ..addFlag(
        'json',
        help: 'Reserved for future machine-readable output.',
        negatable: false,
        hide: true,
      );
  }

  final CommandContext context;

  Logger get logger => context.logger;

  bool get verbose => argResults?['verbose'] == true;

  @override
  Future<int> run() async {
    if (verbose) logger.level = Level.debug;
    return runCommand();
  }

  Future<int> runCommand();
}
