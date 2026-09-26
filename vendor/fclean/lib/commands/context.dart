import '../services/config_service.dart';
import '../services/file_system_service.dart';
import '../services/platform_service.dart';
import '../services/process_service.dart';
import '../services/terminal_service.dart';
import '../utils/logger.dart';

class CommandContext {
  CommandContext({
    required this.logger,
    PlatformService? platform,
    FileSystemService? fileSystem,
    ProcessService? process,
    ConfigService? config,
    TerminalService? terminal,
  })  : platform = platform ?? const PlatformService(),
        fileSystem = fileSystem ?? const FileSystemService(),
        process = process ?? const ProcessService(),
        config = config ?? const ConfigService(),
        terminal = terminal ?? TerminalService(logger: logger);

  final Logger logger;
  final PlatformService platform;
  final FileSystemService fileSystem;
  final ProcessService process;
  final ConfigService config;
  final TerminalService terminal;
}
