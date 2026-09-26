import 'dart:io';

import '../services/config_service.dart';
import '../utils/exceptions.dart';
import 'base_command.dart';

class InitCommand extends FCleanCommand {
  InitCommand(super.context) {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite an existing config file.',
      negatable: false,
    );
  }

  @override
  String get description => 'Generate a fclean.yaml config file.';

  @override
  String get name => 'init';

  @override
  Future<int> runCommand() async {
    final force = argResults!['force'] == true;
    final file = File(ConfigService.fileName);
    if (file.existsSync() && !force) {
      logger.warn(
        '${ConfigService.fileName} already exists. Use --force to overwrite.',
        tag: 'INIT',
      );
      return CleanerExitCode.success.code;
    }

    await context.config.writeDefault(overwrite: force);
    logger.success('Created ${ConfigService.fileName}');
    return CleanerExitCode.success.code;
  }
}
