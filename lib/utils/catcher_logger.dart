import 'dart:developer';

import 'package:flutter/foundation.dart';

enum LogLevel {
  fine(800, '32'), //green
  warning(900, '38;5;216'), //orange
  error(1000, '31'); //red

  const LogLevel(this.level, this.ansiCode);
  final int level;
  final String ansiCode;
}

///Class used to provide logger for Catcher. Only print logs in [kDebugMode]
class CatcherLogger {
  const CatcherLogger._();

  static void _log(
    LogLevel level,
    String message,
  ) {
    if (kDebugMode) {
      if (level == LogLevel.error) {
        log(
          '',
          level: 1000,
          name: 'Catcher',
          error: '[${DateTime.now()} | ${level.name.toUpperCase()}] $message',
        );
      } else {
        debugPrint(
          '\x1b[${level.ansiCode}m[${DateTime.now()} | Catcher | '
          '${level.name.toUpperCase()}] $message\x1b[0m',
        );
      }
    }
  }

  ///Log error message.
  static void error(String message) {
    _log(LogLevel.error, message);
  }

  ///Log fine message.
  static void fine(String message) {
    _log(LogLevel.fine, message);
  }

  ///Log warning message.
  static void warning(String message) {
    _log(LogLevel.warning, message);
  }
}
