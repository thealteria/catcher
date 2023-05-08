import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';

void main() {
  var explicitReportModesMap = {"FormatException": PageReportMode()};
  CatcherOptions debugOptions = CatcherOptions(
    DialogReportMode(),
    [
      ConsoleHandler(),
      HttpHandler(HttpRequestType.post, Uri.parse("https://httpstat.us/200"),
          printLogs: true)
    ],
    explicitExceptionReportModesMap: explicitReportModesMap,
  );
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
    return Column(
      children: <Widget>[
        TextButton(
            child: const Text("Generate first error"),
            onPressed: () => generateFirstError()),
        TextButton(
          child: const Text("Generate second error"),
          onPressed: () => generateSecondError(),
        ),
      ],
    );
  }

  void generateFirstError() async {
    throw const FormatException("Example Error");
  }

  void generateSecondError() async {
    throw ArgumentError("Normal error");
  }
}
