import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';

final navigationKey = GlobalKey<NavigatorState>();

void main() {
  ///Configure your debug options (settings used in development mode)
  CatcherOptions debugOptions = CatcherOptions(
    ///Show information about caught error in dialog
    SilentReportMode(),
    [
      ///Send logs to HTTP server
      HttpHandler(HttpRequestType.post,
          Uri.parse("https://jsonplaceholder.typicode.com/posts"),
          printLogs: true),

      ///Print logs in console
      ConsoleHandler(),
    ],
  );

  ///Configure your production options (settings used in release mode)
  CatcherOptions releaseOptions = CatcherOptions(
    ///Show new page with information about caught error
    PageReportMode(),
    [
      ///Send logs to Crashlytics
      CrashlyticsHandler(
        crashlyticsReport: (String reportMessage, Report report) async {
          await Future<void>.delayed(Duration(seconds: 5));

          //add crashylitics like this to send data
          // final crashlytics = FirebaseCrashlytics.instance;
          // crashlytics.setCrashlyticsCollectionEnabled(true);
          // crashlytics.log(reportMessage);
          // if (report.errorDetails != null) {
          //   await crashlytics.recordFlutterError(
          //     report.errorDetails as FlutterErrorDetails,
          //   );
          // } else {
          //   await crashlytics.recordError(
          //     report.error,
          //     report.stackTrace as StackTrace,
          //   );
          // }
        },
      ),

      ///Print logs in console
      ConsoleHandler(),
    ],
  );

  ///Start Catcher and then start App. Now Catcher will guard and report any
  ///error to your configured services!
  Catcher(
    runAppFunction: () {
      runApp(MyApp());
    },
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
    navigatorKey: navigationKey,
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      ///Last step: add navigator key of Catcher here, so Catcher can show
      ///page and dialog!
      navigatorKey: navigationKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Catcher example"),
        ),
        body: ChildWidget(),
      ),
    );
  }
}

class ChildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        child: Text("Generate error"),
        onPressed: () => generateError(),
      ),
    );
  }

  ///Simply just trigger some error.
  void generateError() async {
    Catcher.sendTestException();
  }
}
