import 'dart:io';

enum Level { quiet, info, debug }

class Logger {
  Logger({this.level = Level.info});

  Level level;

  void info(String message) {
    if (level == Level.quiet) return;
    stdout.writeln(message);
  }

  void success(String message) => info(message);

  void warn(String message, {String? tag}) {
    if (level == Level.quiet) return;
    stderr.writeln(_tagged(message, tag ?? 'WARN'));
  }

  void err(String message) {
    if (level == Level.quiet) return;
    stderr.writeln(message);
  }

  void detail(String message) {
    if (level != Level.debug) return;
    stdout.writeln(message);
  }

  bool confirm(String message, {bool defaultValue = false}) {
    if (level != Level.quiet) {
      final suffix = defaultValue ? '[Y/n]' : '[y/N]';
      stdout.write('$message $suffix ');
    }

    final input = stdin.readLineSync()?.trim().toLowerCase();
    if (input == null || input.isEmpty) return defaultValue;
    return input == 'y' || input == 'yes';
  }

  String prompt(String message, {String defaultValue = ''}) {
    if (level != Level.quiet) {
      final suffix = defaultValue.isEmpty ? '' : ' [$defaultValue]';
      stdout.write('$message$suffix ');
    }

    final input = stdin.readLineSync();
    if (input == null || input.isEmpty) return defaultValue;
    return input;
  }

  String chooseOne(
    String message, {
    required List<String> choices,
    String? defaultValue,
  }) {
    if (choices.isEmpty) return defaultValue ?? '';

    if (level != Level.quiet) {
      stdout.writeln(message);
      for (var index = 0; index < choices.length; index++) {
        stdout.writeln('${index + 1}. ${choices[index]}');
      }
    }

    final fallback = defaultValue ?? choices.first;
    final input = stdin.readLineSync()?.trim();
    final selected = int.tryParse(input ?? '');
    if (selected == null || selected < 1 || selected > choices.length) {
      return fallback;
    }
    return choices[selected - 1];
  }

  String _tagged(String message, String tag) => '[$tag] $message';
}
