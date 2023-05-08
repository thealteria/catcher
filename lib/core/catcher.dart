import 'dart:async';

import 'package:catcher/core/application_profile_manager.dart';
import 'package:catcher/core/catcher_screenshot_manager.dart';
import 'package:catcher/mode/report_mode_action_confirmed.dart';
import 'package:catcher/model/application_profile.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:catcher/model/localization_options.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report.dart';
import 'package:catcher/model/report_handler.dart';
import 'package:catcher/model/report_mode.dart';
import 'package:catcher/utils/catcher_error_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Catcher with ReportModeAction {
  static late Catcher _instance;
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Root widget which will be ran
  final Widget? rootWidget;

  ///Run app function which will be ran
  final void Function()? runAppFunction;

  /// Instance of catcher config used in release mode
  CatcherOptions? releaseConfig;

  /// Instance of catcher config used in debug mode
  CatcherOptions? debugConfig;

  /// Instance of catcher config used in profile mode
  CatcherOptions? profileConfig;

  /// Should catcher run WidgetsFlutterBinding.ensureInitialized() during initialization.
  final bool ensureInitialized;

  late CatcherOptions _currentConfig;
  late CatcherScreenshotManager screenshotManager;
  final Map<String, dynamic> _deviceParameters = <String, dynamic>{};
  final Map<String, dynamic> _applicationParameters = <String, dynamic>{};
  final List<Report> _cachedReports = [];
  final Map<DateTime, String> _reportsOcurrenceMap = {};
  LocalizationOptions? _localizationOptions;

  /// Instance of navigator key
  static GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  /// Builds catcher instance
  Catcher({
    this.rootWidget,
    this.runAppFunction,
    this.releaseConfig,
    this.debugConfig,
    this.profileConfig,
    this.ensureInitialized = false,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : assert(
          rootWidget != null || runAppFunction != null,
          "You need to provide rootWidget or runAppFunction",
        ) {
    _configure(navigatorKey);
  }

  void _configure(GlobalKey<NavigatorState>? navigatorKey) {
    _instance = this;
    _configureNavigatorKey(navigatorKey);
    _setupCurrentConfig();
    _setupErrorHooks();
    _setupReportModeActionInReportMode();
    _setupScreenshotManager();

    _loadDeviceInfo();
    _loadApplicationInfo();

    if (_currentConfig.handlers.isEmpty) {
      CatcherLogger.warning(
        "Handlers list is empty. Configure at least one handler to "
        "process error reports.",
      );
    } else {
      CatcherLogger.fine("Catcher configured successfully.");
    }
  }

  void _configureNavigatorKey(GlobalKey<NavigatorState>? navigatorKey) {
    if (navigatorKey != null) {
      _navigatorKey = navigatorKey;
    } else {
      _navigatorKey = GlobalKey<NavigatorState>();
    }
  }

  void _setupCurrentConfig() {
    switch (ApplicationProfileManager.getApplicationProfile()) {
      case ApplicationProfile.release:
        {
          if (releaseConfig != null) {
            _currentConfig = releaseConfig!;
          } else {
            _currentConfig = CatcherOptions.getDefaultReleaseOptions();
          }
          break;
        }
      case ApplicationProfile.debug:
        {
          if (debugConfig != null) {
            _currentConfig = debugConfig!;
          } else {
            _currentConfig = CatcherOptions.getDefaultDebugOptions();
          }
          break;
        }
      case ApplicationProfile.profile:
        {
          if (profileConfig != null) {
            _currentConfig = profileConfig!;
          } else {
            _currentConfig = CatcherOptions.getDefaultProfileOptions();
          }
          break;
        }
    }
  }

  ///Update config after initialization
  void updateConfig({
    CatcherOptions? debugConfig,
    CatcherOptions? profileConfig,
    CatcherOptions? releaseConfig,
  }) {
    if (debugConfig != null) {
      this.debugConfig = debugConfig;
    }
    if (profileConfig != null) {
      this.profileConfig = profileConfig;
    }
    if (releaseConfig != null) {
      this.releaseConfig = releaseConfig;
    }
    _setupCurrentConfig();
    _setupReportModeActionInReportMode();
    _setupScreenshotManager();
    _localizationOptions = null;
  }

  void _setupReportModeActionInReportMode() {
    _currentConfig.reportMode.setReportModeAction(this);
    _currentConfig.explicitExceptionReportModesMap.forEach(
      (error, reportMode) {
        reportMode.setReportModeAction(this);
      },
    );
  }

  void _setupLocalizationsOptionsInReportMode() {
    _currentConfig.reportMode.setLocalizationOptions(_localizationOptions);
    _currentConfig.explicitExceptionReportModesMap.forEach(
      (error, reportMode) {
        reportMode.setLocalizationOptions(_localizationOptions);
      },
    );
  }

  void _setupLocalizationsOptionsInReportsHandler() {
    for (var handler in _currentConfig.handlers) {
      handler.setLocalizationOptions(_localizationOptions);
    }
  }

  Future _setupErrorHooks() async {
    FlutterError.onError = (FlutterErrorDetails details) async {
      _reportError(details.exception, details.stack, errorDetails: details);
    };

    // Isolate.current.addErrorListener(
    //   RawReceivePort((pair) async {
    //     final isolateError = pair as List<dynamic>;
    //     CatcherLogger.fine('isolateError: $isolateError');
    //     _reportError(
    //       isolateError.first.toString(),
    //       StackTrace.fromString(isolateError.last.toString()),
    //     );
    //   }).sendPort,
    // );

    if (rootWidget != null) {
      _runZonedGuarded(() {
        runApp(rootWidget!);
      });
    } else if (runAppFunction != null) {
      _runZonedGuarded(() {
        runAppFunction!();
      });
    } else {
      throw ArgumentError("Provide rootWidget or runAppFunction to Catcher.");
    }
  }

  void _runZonedGuarded(void Function() callback) {
    runZonedGuarded<Future<void>>(() async {
      if (ensureInitialized) {
        WidgetsFlutterBinding.ensureInitialized();
      }
      callback();
    }, (dynamic error, StackTrace stackTrace) {
      _reportError(error, stackTrace);
    });
  }

  void _loadDeviceInfo() {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (ApplicationProfileManager.isAndroid()) {
      deviceInfo.androidInfo.then((androidInfo) {
        _loadAndroidParameters(androidInfo);
        _removeExcludedParameters();
      });
    } else if (ApplicationProfileManager.isIos()) {
      deviceInfo.iosInfo.then((iosInfo) {
        _loadIosParameters(iosInfo);
        _removeExcludedParameters();
      });
    } else {
      CatcherLogger.error(
          "Couldn't load device info for unsupported device type.");
    }
  }

  ///Remove excluded parameters from device parameters.
  void _removeExcludedParameters() {
    for (var parameter in _currentConfig.excludedParameters) {
      _deviceParameters.remove(parameter);
    }
  }

  void _loadAndroidParameters(AndroidDeviceInfo androidDeviceInfo) {
    try {
      _deviceParameters["id"] = androidDeviceInfo.id;
      // TODO(*): _deviceParameters["androidId"] = androidDeviceInfo.androidId;
      _deviceParameters["board"] = androidDeviceInfo.board;
      _deviceParameters["bootloader"] = androidDeviceInfo.bootloader;
      _deviceParameters["brand"] = androidDeviceInfo.brand;
      _deviceParameters["device"] = androidDeviceInfo.device;
      _deviceParameters["display"] = androidDeviceInfo.display;
      _deviceParameters["fingerprint"] = androidDeviceInfo.fingerprint;
      _deviceParameters["hardware"] = androidDeviceInfo.hardware;
      _deviceParameters["host"] = androidDeviceInfo.host;
      _deviceParameters["isPhysicalDevice"] =
          androidDeviceInfo.isPhysicalDevice;
      _deviceParameters["manufacturer"] = androidDeviceInfo.manufacturer;
      _deviceParameters["model"] = androidDeviceInfo.model;
      _deviceParameters["product"] = androidDeviceInfo.product;
      _deviceParameters["tags"] = androidDeviceInfo.tags;
      _deviceParameters["type"] = androidDeviceInfo.type;
      _deviceParameters["versionBaseOs"] = androidDeviceInfo.version.baseOS;
      _deviceParameters["versionCodename"] = androidDeviceInfo.version.codename;
      _deviceParameters["versionIncremental"] =
          androidDeviceInfo.version.incremental;
      _deviceParameters["versionPreviewSdk"] =
          androidDeviceInfo.version.previewSdkInt;
      _deviceParameters["versionRelease"] = androidDeviceInfo.version.release;
      _deviceParameters["versionSdk"] = androidDeviceInfo.version.sdkInt;
      _deviceParameters["versionSecurityPatch"] =
          androidDeviceInfo.version.securityPatch;
    } catch (exception) {
      CatcherLogger.warning("Load Android parameters failed: $exception");
    }
  }

  void _loadIosParameters(IosDeviceInfo iosInfo) {
    try {
      _deviceParameters["model"] = iosInfo.model;
      _deviceParameters["isPhysicalDevice"] = iosInfo.isPhysicalDevice;
      _deviceParameters["name"] = iosInfo.name;
      _deviceParameters["identifierForVendor"] = iosInfo.identifierForVendor;
      _deviceParameters["localizedModel"] = iosInfo.localizedModel;
      _deviceParameters["systemName"] = iosInfo.systemName;
      _deviceParameters["utsnameVersion"] = iosInfo.utsname.version;
      _deviceParameters["utsnameRelease"] = iosInfo.utsname.release;
      _deviceParameters["utsnameMachine"] = iosInfo.utsname.machine;
      _deviceParameters["utsnameNodename"] = iosInfo.utsname.nodename;
      _deviceParameters["utsnameSysname"] = iosInfo.utsname.sysname;
    } catch (exception) {
      CatcherLogger.warning("Load iOS parameters failed: $exception");
    }
  }

  void _loadApplicationInfo() {
    _applicationParameters["environment"] =
        describeEnum(ApplicationProfileManager.getApplicationProfile());

    PackageInfo.fromPlatform().then((packageInfo) {
      _applicationParameters["version"] = packageInfo.version;
      _applicationParameters["appName"] = packageInfo.appName;
      _applicationParameters["buildNumber"] = packageInfo.buildNumber;
      _applicationParameters["packageName"] = packageInfo.packageName;
    });
  }

  ///We need to setup localizations lazily because context needed to setup these
  ///localizations can be used after app was build for the first time.
  void _setupLocalization() {
    Locale locale = const Locale("en", "US");
    if (_isContextValid()) {
      final BuildContext? context = _getContext();
      if (context != null) {
        locale = Localizations.localeOf(context);
      }
      if (_currentConfig.localizationOptions.isNotEmpty == true) {
        for (final options in _currentConfig.localizationOptions) {
          if (options.languageCode.toLowerCase() ==
              locale.languageCode.toLowerCase()) {
            _localizationOptions = options;
          }
        }
      }
    }

    _localizationOptions ??=
        _getDefaultLocalizationOptionsForLanguage(locale.languageCode);
    _setupLocalizationsOptionsInReportMode();
    _setupLocalizationsOptionsInReportsHandler();
  }

  LocalizationOptions _getDefaultLocalizationOptionsForLanguage(
    String language,
  ) {
    switch (language.toLowerCase()) {
      case "en":
        return LocalizationOptions.buildDefaultEnglishOptions();
      case "hi":
        return LocalizationOptions.buildDefaultHindiOptions();
      default:
        return LocalizationOptions.buildDefaultEnglishOptions();
    }
  }

  ///Setup screenshot manager's screenshots path.
  void _setupScreenshotManager() {
    screenshotManager = CatcherScreenshotManager();
    final String screenshotsPath = _currentConfig.screenshotsPath;
    if (screenshotsPath.isEmpty) {
      CatcherLogger.warning(
          "Screenshots path is empty. Screenshots won't work.");
    }
    screenshotManager.path = screenshotsPath;
  }

  /// Report checked error (error caught in try-catch block). Catcher will treat
  /// this as normal exception and pass it to handlers.
  static void reportCheckedError({
    Object? error,
    StackTrace? stackTrace,
  }) {
    _instance._reportError(
      error ?? 'undefined error',
      stackTrace,
    );
  }

  void _reportError(
    Object error,
    StackTrace? stackTrace, {
    FlutterErrorDetails? errorDetails,
  }) async {
    if (errorDetails?.silent == true &&
        _currentConfig.handleSilentError == false) {
      CatcherLogger.error(
        "Report error skipped for error: $error. HandleSilentError is false.",
      );
      return;
    }

    if (_localizationOptions == null) {
      CatcherLogger.fine("Setup localization lazily!");
      _setupLocalization();
    }

    _cleanPastReportsOccurences();

    final screenshot = await screenshotManager.captureAndSave();

    final Report report = Report(
      error,
      stackTrace ?? StackTrace.current,
      DateTime.now(),
      _deviceParameters,
      _applicationParameters,
      _currentConfig.customParameters,
      errorDetails,
      _getPlatformType(),
      screenshot,
    );

    if (_isReportInReportsOccurencesMap(report)) {
      CatcherLogger.fine(
        "Error: '$error' has been skipped to due to duplication occurence within ${_currentConfig.reportOccurrenceTimeout} ms.",
      );
      return;
    }

    if (_currentConfig.filterFunction != null &&
        _currentConfig.filterFunction!(report) == false) {
      CatcherLogger.fine(
        "Error: '$error' has been filtered from Catcher logs. Report will be skipped.",
      );
      return;
    }
    _cachedReports.add(report);
    ReportMode? reportMode =
        _getReportModeFromExplicitExceptionReportModeMap(error);
    if (reportMode != null) {
      CatcherLogger.error("Using explicit report mode for error");
    } else {
      reportMode = _currentConfig.reportMode;
    }
    if (!isReportModeSupportedInPlatform(report, reportMode)) {
      CatcherLogger.warning(
        "$reportMode in not supported for ${describeEnum(report.platformType)} platform",
      );
      return;
    }

    _addReportInReportsOccurencesMap(report);

    if (reportMode.isContextRequired()) {
      if (_isContextValid()) {
        reportMode.requestAction(report, _getContext());
      } else {
        CatcherLogger.warning(
          "Couldn't use report mode because you didn't provide navigator key. Add navigator key to use this report mode.",
        );
      }
    } else {
      reportMode.requestAction(report, null);
    }
  }

  /// Check if given report mode is enabled in current platform. Only supported
  /// handlers in given report mode can be used.
  bool isReportModeSupportedInPlatform(Report report, ReportMode reportMode) {
    if (reportMode.getSupportedPlatforms().isEmpty) {
      return false;
    }
    return reportMode.getSupportedPlatforms().contains(report.platformType);
  }

  ReportMode? _getReportModeFromExplicitExceptionReportModeMap(dynamic error) {
    final errorName = error != null ? error.toString().toLowerCase() : "";
    ReportMode? reportMode;
    _currentConfig.explicitExceptionReportModesMap.forEach((key, value) {
      if (errorName.contains(key.toLowerCase())) {
        reportMode = value;
        return;
      }
    });
    return reportMode;
  }

  ReportHandler? _getReportHandlerFromExplicitExceptionHandlerMap(
    dynamic error,
  ) {
    final errorName = error != null ? error.toString().toLowerCase() : "";
    ReportHandler? reportHandler;
    _currentConfig.explicitExceptionHandlersMap.forEach((key, value) {
      if (errorName.contains(key.toLowerCase())) {
        reportHandler = value;
        return;
      }
    });
    return reportHandler;
  }

  @override
  void onActionConfirmed(Report report) {
    final ReportHandler? reportHandler =
        _getReportHandlerFromExplicitExceptionHandlerMap(report.error);
    if (reportHandler != null) {
      CatcherLogger.error("Using explicit report handler");
      _handleReport(report, reportHandler);
      return;
    }

    for (final ReportHandler handler in _currentConfig.handlers) {
      _handleReport(report, handler);
    }
  }

  void _handleReport(Report report, ReportHandler reportHandler) {
    if (!isReportHandlerSupportedInPlatform(report, reportHandler)) {
      CatcherLogger.warning(
        "${reportHandler.reportHandlerName()} in not supported for ${describeEnum(report.platformType)} platform",
      );
      return;
    }

    if (reportHandler.isContextRequired() && !_isContextValid()) {
      CatcherLogger.warning(
        "Couldn't use report handler because you didn't provide navigator key. Add navigator key to use this report mode.",
      );
      return;
    }

    reportHandler
        .handle(report, _getContext())
        .catchError((dynamic handlerError) {
      CatcherLogger.warning(
        "Error occurred in ${reportHandler.toString()}: ${handlerError.toString()}",
      );
      return false;
    }).then((result) {
      CatcherLogger.fine(
        "${reportHandler.reportHandlerName()} result: $result",
      );
      if (!result) {
        CatcherLogger.warning(
          "${reportHandler.reportHandlerName()} failed to report error",
        );
      } else {
        _cachedReports.remove(report);
      }

      return result;
    }).timeout(
      Duration(milliseconds: _currentConfig.handlerTimeout),
      onTimeout: () {
        CatcherLogger.warning(
          "${reportHandler.reportHandlerName()} failed to report error because of timeout",
        );

        return false;
      },
    );
  }

  /// Checks is report handler is supported in given platform. Only supported
  /// report handlers in given platform can be used.
  bool isReportHandlerSupportedInPlatform(
    Report report,
    ReportHandler reportHandler,
  ) {
    if (reportHandler.getSupportedPlatforms().isEmpty == true) {
      return false;
    }
    return reportHandler.getSupportedPlatforms().contains(report.platformType);
  }

  @override
  void onActionRejected(Report report) {
    _currentConfig.handlers
        .where((handler) => handler.shouldHandleWhenRejected())
        .forEach((handler) {
      _handleReport(report, handler);
    });

    _cachedReports.remove(report);
  }

  BuildContext? _getContext() {
    return navigatorKey?.currentState?.overlay?.context;
  }

  bool _isContextValid() {
    return navigatorKey?.currentState?.overlay != null;
  }

  /// Get currently used config.
  CatcherOptions? getCurrentConfig() {
    return _currentConfig;
  }

  /// Send text exception. Used to test Catcher configuration.
  static void sendTestException() {
    throw const FormatException("Test exception generated by Catcher");
  }

  /// Add default error widget which replaces red screen of death (RSOD).
  static void addDefaultErrorWidget({
    bool showStacktrace = true,
    String title = "An application error has occurred",
    String description =
        "There was unexpected situation in application. Application has been "
            "able to recover from error state.",
    double maxWidthForSmallMode = 150,
  }) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return CatcherErrorWidget(
        details: details,
        showStacktrace: showStacktrace,
        title: title,
        description: description,
        maxWidthForSmallMode: maxWidthForSmallMode,
      );
    };
  }

  ///Get platform type based on device.
  PlatformType _getPlatformType() {
    if (ApplicationProfileManager.isAndroid()) {
      return PlatformType.android;
    }
    if (ApplicationProfileManager.isIos()) {
      return PlatformType.iOS;
    }

    return PlatformType.unknown;
  }

  ///Clean report ocucrences from the past.
  void _cleanPastReportsOccurences() {
    final int occurenceTimeout = _currentConfig.reportOccurrenceTimeout;
    final DateTime nowDateTime = DateTime.now();
    _reportsOcurrenceMap.removeWhere((key, value) {
      final DateTime occurenceWithTimeout =
          key.add(Duration(milliseconds: occurenceTimeout));
      return nowDateTime.isAfter(occurenceWithTimeout);
    });
  }

  ///Check whether reports occurence map contains given report.
  bool _isReportInReportsOccurencesMap(Report report) {
    if (report.error != null) {
      return _reportsOcurrenceMap.containsValue(report.error.toString());
    } else {
      return false;
    }
  }

  ///Add report in reports occurences map. Report will be added only when
  ///error is not null and report occurence timeout is greater than 0.
  void _addReportInReportsOccurencesMap(Report report) {
    if (report.error != null && _currentConfig.reportOccurrenceTimeout > 0) {
      _reportsOcurrenceMap[DateTime.now()] = report.error.toString();
    }
  }

  ///Get current Catcher instance.
  static Catcher getInstance() {
    return _instance;
  }
}
