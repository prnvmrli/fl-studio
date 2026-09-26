import 'package:args/command_runner.dart';

import 'analyze_command.dart';
import 'cache_command.dart';
import 'clean_command.dart';
import 'context.dart';
import 'doctor_command.dart';
import 'init_command.dart';
import 'scan_command.dart';
import '../utils/logger.dart';

CommandRunner<int> buildCommandRunner({Logger? logger}) {
  final context = CommandContext(logger: logger ?? Logger());
  return CommandRunner<int>(
    'fclean',
    'Safely clean Flutter build artifacts, caches, and local development clutter.',
  )
    ..addCommand(CleanCommand(context))
    ..addCommand(ScanCommand(context))
    ..addCommand(AnalyzeCommand(context))
    ..addCommand(DoctorCommand(context))
    ..addCommand(CacheCommand(context))
    ..addCommand(InitCommand(context));
}
