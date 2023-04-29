import 'package:catcher/model/report_handler.dart';
import 'package:flutter/material.dart';

import '../model/platform_type.dart';
import '../model/report.dart';

typedef CrashlyticsReport = Future<void> Function(
  String reportMessage,
  Report report,
);

class CrashlyticsHandler extends ReportHandler {
  final bool enableDeviceParameters;
  final bool enableApplicationParameters;
  final bool enableCustomParameters;
  final bool printLogs;
  final CrashlyticsReport crashlyticsReport;

  CrashlyticsHandler({
    this.enableDeviceParameters = true,
    this.enableApplicationParameters = true,
    this.enableCustomParameters = true,
    this.printLogs = true,
    required this.crashlyticsReport,
  });

  @override
  List<PlatformType> getSupportedPlatforms() {
    return [PlatformType.android, PlatformType.iOS];
  }

  @override
  Future<bool> handle(Report report, BuildContext? context) async {
    try {
      _printLog("Sending crashlytics report");

      await crashlyticsReport(_getLogMessage(report), report);

      _printLog("Crashlytics report sent");
      return true;
    } catch (exception) {
      _printLog(
        "Failed to send crashlytics report: $exception",
        isError: true,
      );
      return false;
    }
  }

  String _getLogMessage(Report report) {
    StringBuffer buffer = StringBuffer("");
    if (enableDeviceParameters) {
      buffer.write("||| Device parameters ||| ");
      for (var entry in report.deviceParameters.entries) {
        buffer.write("${entry.key}: ${entry.value} ");
      }
    }
    if (enableApplicationParameters) {
      buffer.write("||| Application parameters ||| ");
      for (var entry in report.applicationParameters.entries) {
        buffer.write("${entry.key}: ${entry.value} ");
      }
    }
    if (enableCustomParameters) {
      buffer.write("||| Custom parameters ||| ");
      for (var entry in report.customParameters.entries) {
        buffer.write("${entry.key}: ${entry.value} ");
      }
    }
    return buffer.toString();
  }

  void _printLog(String log, {bool isError = false}) {
    if (printLogs) {
      if (isError) {
        CatcherLogger.error(log);
      } else {
        CatcherLogger.fine(log);
      }
    }
  }
}
