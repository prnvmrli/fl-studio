import 'dart:io';

class ProcessService {
  const ProcessService();

  static Map<String, String>? _cachedEnvironment;

  static Map<String, String> _buildEnvironment() {
    if (_cachedEnvironment != null) return _cachedEnvironment!;

    final env = Map<String, String>.from(Platform.environment);
    final currentPath = env['PATH'] ?? '';
    final separator = Platform.isWindows ? ';' : ':';

    if (Platform.isMacOS || Platform.isLinux) {
      final home = env['HOME'] ?? '';
      final candidatePaths = [
        '/opt/homebrew/bin',
        '/opt/homebrew/sbin',
        '/usr/local/bin',
        '/usr/bin',
        '/bin',
        '/usr/sbin',
        '/sbin',
        if (home.isNotEmpty) ...[
          '$home/.fvm/default/bin',
          '$home/.pub-cache/bin',
          '$home/development/flutter/bin',
          '$home/flutter/bin',
          '$home/Library/Android/sdk/platform-tools',
          '$home/Library/Android/sdk/cmdline-tools/latest/bin',
          '$home/.cargo/bin',
        ],
      ];

      final existingSegments =
          currentPath.split(separator).where((s) => s.isNotEmpty).toSet();
      final newSegments = <String>[...existingSegments];

      for (final p in candidatePaths) {
        if (!existingSegments.contains(p) && Directory(p).existsSync()) {
          newSegments.insert(0, p);
        }
      }

      env['PATH'] = newSegments.join(separator);
    }

    _cachedEnvironment = env;
    return env;
  }

  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) {
    final mergedEnv = {
      ..._buildEnvironment(),
      if (environment != null) ...environment,
    };
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: mergedEnv,
      runInShell: true,
    );
  }

  Future<bool> isAvailable(String executable) async {
    final lookup = Platform.isWindows ? 'where' : 'which';
    final result = await run(lookup, [executable]);
    return result.exitCode == 0;
  }
}
