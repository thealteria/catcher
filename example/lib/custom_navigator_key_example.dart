import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';

void main() {
  CatcherOptions debugOptions =
      CatcherOptions(DialogReportMode(), [ConsoleHandler()]);
  CatcherOptions releaseOptions = CatcherOptions(PageReportMode(), [
    HttpHandler(HttpRequestType.post,
        Uri.parse("https://jsonplaceholder.typicode.com/posts"),
        printLogs: true),
  ]);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Catcher(
    rootWidget: MyApp(navigatorKey),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
    navigatorKey: navigatorKey,
  );
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp(this.navigatorKey, {super.key});

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
      navigatorKey: widget.navigatorKey,
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
