import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report.dart';
import 'package:flutter/material.dart';

import 'localization_options.dart';

export '../utils/catcher_logger.dart';

abstract class ReportHandler {
  String reportHandlerName() {
    return runtimeType.toString();
  }

  /// Method called when report has been accepted by user
  Future<bool> handle(Report report, BuildContext? context);

  /// Get list of supported platforms
  List<PlatformType> getSupportedPlatforms();

  ///Location settings
  LocalizationOptions? _localizationOptions;

  /// Get currently used localization options
  LocalizationOptions get localizationOptions =>
      _localizationOptions ?? LocalizationOptions.buildDefaultEnglishOptions();

  // ignore: use_setters_to_change_properties
  /// Set localization options (translations) to this report mode
  void setLocalizationOptions(LocalizationOptions? localizationOptions) {
    _localizationOptions = localizationOptions;
  }

  /// Check if given report mode requires context to run
  bool isContextRequired() {
    return false;
  }

  /// Check whether report mode should auto confirm without user confirmation.
  bool shouldHandleWhenRejected() {
    return false;
  }
}
