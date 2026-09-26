import 'dart:async';
import 'dart:io';

import 'package:interact/interact.dart' as interact;

import '../utils/logger.dart';

class TerminalService {
  TerminalService({required this.logger});

  final Logger logger;

  bool get isInteractive => stdin.hasTerminal;

  bool confirm(
    String message, {
    bool defaultValue = false,
    bool assumeYes = false,
  }) {
    if (assumeYes) return true;
    if (!isInteractive) return defaultValue;

    try {
      return interact.Confirm(
        prompt: message,
        defaultValue: defaultValue,
      ).interact();
    } catch (_) {
      return logger.confirm(message, defaultValue: defaultValue);
    }
  }

  String prompt(String message, {String defaultValue = ''}) {
    if (!isInteractive) return defaultValue;
    return logger.prompt(message, defaultValue: defaultValue);
  }

  String chooseOne(
    String message, {
    required List<String> choices,
    String? defaultValue,
  }) {
    if (!isInteractive) return defaultValue ?? choices.first;
    return logger.chooseOne(
      message,
      choices: choices,
      defaultValue: defaultValue,
    );
  }

  Future<T> withSpinner<T>(String message, Future<T> Function() action) {
    if (!stderr.hasTerminal) return action();

    logger.info(message);
    return action();
  }
}
