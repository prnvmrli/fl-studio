class CleanerException implements Exception {
  const CleanerException(this.message, {this.exitCode = 1});

  final String message;
  final int exitCode;

  @override
  String toString() => message;
}

abstract final class CleanerExitCode {
  static const success = _ExitCode(0);
  static const usage = _ExitCode(64);
  static const unavailable = _ExitCode(69);
  static const software = _ExitCode(70);
}

class _ExitCode {
  const _ExitCode(this.code);

  final int code;
}
