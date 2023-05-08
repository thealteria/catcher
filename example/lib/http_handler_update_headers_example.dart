import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';

void main() {
  ///Http handler instance
  var httpHandler = HttpHandler(
    HttpRequestType.post,
    Uri.parse("https://jsonplaceholder.typicode.com/posts"),
    printLogs: true,
    enableCustomParameters: false,
    enableStackTrace: false,
    enableApplicationParameters: false,
    enableDeviceParameters: false,
  );

  ///Init catcher
  CatcherOptions debugOptions =
      CatcherOptions(DialogReportMode(), [httpHandler, ConsoleHandler()]);
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

  ///At some point of time, you're updating headers:

  httpHandler.headers.clear();
  httpHandler.headers["my_header"] = "Test";
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
