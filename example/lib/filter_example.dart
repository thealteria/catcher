import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';

void main() {
  CatcherOptions debugOptions = CatcherOptions(DialogReportMode(), [
    ConsoleHandler(),
  ], filterFunction: (Report report) {
    if (report.error is ArgumentError) {
      return false;
    } else {
      return true;
    }
  });
  CatcherOptions releaseOptions = CatcherOptions(PageReportMode(), [
    HttpHandler(HttpRequestType.post,
        Uri.parse("https://jsonplaceholder.typicode.com/posts"),
        printLogs: true),
  ]);

  Catcher(
    runAppFunction: () {
      runApp(const MyApp());
    },
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
          title: const Text('Filter example'),
        ),
        body: Column(
          children: [
            TextButton(
              child: const Text("Generate normal error"),
              onPressed: () => generateNormalError(),
            ),
            TextButton(
              child: const Text("Generate filtered error"),
              onPressed: () => generateFilteredError(),
            ),
          ],
        ),
      ),
    );
  }

  void generateNormalError() async {
    throw StateError("Example error");
  }

  void generateFilteredError() async {
    throw ArgumentError("Example error");
  }
}
