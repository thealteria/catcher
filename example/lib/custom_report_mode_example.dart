import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:flutter/material.dart';

void main() {
  CatcherOptions debugOptions =
      CatcherOptions(CustomPageReportMode(), [ConsoleHandler()]);
  CatcherOptions releaseOptions = CatcherOptions(PageReportMode(), [
    HttpHandler(HttpRequestType.post,
        Uri.parse("https://jsonplaceholder.typicode.com/posts"),
        printLogs: true),
  ]);

  Catcher(
    rootWidget: const MyApp(),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Catcher.navigatorKey,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: const ChildWidget()),
    );
  }
}

class ChildWidget extends StatelessWidget {
  const ChildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text("Generate error"),
      onPressed: () => generateError(),
    );
  }

  void generateError() async {
    Catcher.sendTestException();
  }
}

class CustomPageReportMode extends ReportMode {
  @override
  void requestAction(Report report, BuildContext? context) {
    if (context != null) {
      _navigateToPageWidget(report, context);
    }
  }

  Future<void> _navigateToPageWidget(
      Report report, BuildContext context) async {
    await Future<void>.delayed(
      Duration.zero,
      () {
        Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (context) => CustomPage(this, report)),
        );
      },
    );
  }

  @override
  bool isContextRequired() {
    return true;
  }

  @override
  List<PlatformType> getSupportedPlatforms() =>
      [PlatformType.android, PlatformType.iOS];
}

class CustomPage extends StatelessWidget {
  final ReportMode reportMode;
  final Report report;

  const CustomPage(this.reportMode, this.report, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      body: Row(
        children: [
          ElevatedButton(
            child: const Text("Send report"),
            onPressed: () {
              reportMode.onActionConfirmed(report);
            },
          ),
          ElevatedButton(
            child: const Text("Cancel report"),
            onPressed: () {
              reportMode.onActionRejected(report);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
