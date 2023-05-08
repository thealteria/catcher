import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report.dart';
import 'package:catcher/model/report_handler.dart';
import 'package:flutter/material.dart';

class ConsoleHandler extends ReportHandler {
  final bool enableDeviceParameters;
  final bool enableApplicationParameters;
  final bool enableStackTrace;
  final bool enableCustomParameters;
  final bool handleWhenRejected;

  ConsoleHandler({
    this.enableDeviceParameters = true,
    this.enableApplicationParameters = true,
    this.enableStackTrace = true,
    this.enableCustomParameters = false,
    this.handleWhenRejected = false,
  });

  @override
  Future<bool> handle(Report report, BuildContext? context) {
    CatcherLogger.error(
      "============================== CATCHER LOG ==============================",
    );
    CatcherLogger.error("Crash occurred on ${report.dateTime}");
    CatcherLogger.error("");
    if (enableDeviceParameters) {
      _printDeviceParametersFormatted(report.deviceParameters);
      CatcherLogger.error("");
    }
    if (enableApplicationParameters) {
      _printApplicationParametersFormatted(report.applicationParameters);
      CatcherLogger.error("");
    }
    CatcherLogger.error("---------- ERROR ----------");
    CatcherLogger.error("${report.error}");
    CatcherLogger.error("");
    if (enableStackTrace) {
      _printStackTraceFormatted(report.stackTrace);
    }
    if (enableCustomParameters) {
      _printCustomParametersFormatted(report.customParameters);
    }
    CatcherLogger.error(
      "======================================================================",
    );
    return Future.value(true);
  }

  void _printDeviceParametersFormatted(Map<String, dynamic> deviceParameters) {
    _printLog('DEVICE INFO', deviceParameters.entries);
  }

  void _printApplicationParametersFormatted(
    Map<String, dynamic> applicationParameters,
  ) {
    _printLog('APP INFO', applicationParameters.entries);
  }

  void _printCustomParametersFormatted(Map<String, dynamic> customParameters) {
    _printLog('CUSTOM INFO', customParameters.entries);
  }

  void _printStackTraceFormatted(StackTrace? stackTrace) {
    _printLog('STACK TRACE', stackTrace.toString().split('\n'));
  }

  void _printLog(String title, Object entries) {
    String message = '------- $title -------\n';

    if (entries is Iterable<MapEntry<String, dynamic>>) {
      for (final entry in entries) {
        message += '${entry.key}: ${entry.value}\n';
      }
    } else if (entries is List<String>) {
      for (final entry in entries) {
        message += '$entry\n';
      }
    }
    CatcherLogger.error(message);
  }

  @override
  List<PlatformType> getSupportedPlatforms() => [
        PlatformType.android,
        PlatformType.iOS,
      ];

  @override
  bool shouldHandleWhenRejected() {
    return handleWhenRejected;
  }
}
