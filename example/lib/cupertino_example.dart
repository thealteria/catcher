import 'package:catcher/catcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  CatcherOptions debugOptions = CatcherOptions(DialogReportMode(), [
    HttpHandler(HttpRequestType.post,
        Uri.parse("https://jsonplaceholder.typicode.com/posts"),
        printLogs: true),
    ConsoleHandler()
  ]);
  CatcherOptions releaseOptions = CatcherOptions(PageReportMode(), [
    HttpHandler(HttpRequestType.post,
        Uri.parse("https://jsonplaceholder.typicode.com/posts"),
        printLogs: true),
  ]);

  Catcher(
      rootWidget: const MyApp(),
      debugConfig: debugOptions,
      releaseConfig: releaseOptions);
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
    return CupertinoApp(
      navigatorKey: Catcher.navigatorKey,
      home: const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Cupertino example'),
        ),
        child: SafeArea(
          child: ChildWidget(),
        ),
      ),
    );
  }
}

class ChildWidget extends StatelessWidget {
  const ChildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      child: TextButton(
        child: const Text("Generate error"),
        onPressed: () => generateError(),
      ),
    );
  }

  void generateError() async {
    Catcher.sendTestException();
  }
}
