import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';

late Catcher catcher;

void main() {
  Map<String, dynamic> customParameters = <String, dynamic>{};
  customParameters["First"] = "First parameter";
  CatcherOptions debugOptions = CatcherOptions(
      PageReportMode(),
      [
        ConsoleHandler(enableCustomParameters: true),
      ],
      customParameters: customParameters);
  CatcherOptions releaseOptions = CatcherOptions(PageReportMode(), [
    HttpHandler(HttpRequestType.post,
        Uri.parse("https://jsonplaceholder.typicode.com/posts"),
        printLogs: true),
  ]);

  catcher = Catcher(
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
      children: [
        ElevatedButton(
            onPressed: _changeCustomParameters,
            child: const Text("Change custom parameters")),
        ElevatedButton(
            child: const Text("Generate error"),
            onPressed: () => generateError())
      ],
    );
  }

  void generateError() async {
    Catcher.sendTestException();
  }

  void _changeCustomParameters() {
    CatcherOptions options = catcher.getCurrentConfig()!;
    options.customParameters["Second"] = "Second parameter";
  }
}
