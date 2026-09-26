import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fclean/fclean.dart';

Future<void> main(List<String> arguments) async {
  final logger = Logger();
  final runner = buildCommandRunner(logger: logger);

  try {
    final exitCode =
        await runner.run(arguments) ?? CleanerExitCode.success.code;
    exit(exitCode);
  } on UsageException catch (error) {
    logger
      ..err(error.message)
      ..info('')
      ..info(error.usage);
    exit(CleanerExitCode.usage.code);
  } on CleanerException catch (error) {
    logger.err(error.message);
    exit(error.exitCode);
  } catch (error, stackTrace) {
    logger
      ..err('Unexpected failure: $error')
      ..detail(stackTrace.toString());
    exit(CleanerExitCode.software.code);
  }
}
