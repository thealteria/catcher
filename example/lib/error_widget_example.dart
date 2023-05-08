import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';

void main() {
  CatcherOptions debugOptions = CatcherOptions(SilentReportMode(), [
    ConsoleHandler(),
  ]);
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
      builder: (BuildContext context, Widget? widget) {
        Catcher.addDefaultErrorWidget(
            showStacktrace: true,
            title: "Custom title",
            description: "Custom description",
            maxWidthForSmallMode: 150);
        return widget!;
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _buildSmallErrorWidget(),
      ),
    );
  }

  ///Trigger "normal" mode
  /*Widget _buildNormalErrorWidget() {
    return ChildWidget();
  }*/

  ///Trigger "small" mode
  Widget _buildSmallErrorWidget() {
    return GridView.count(crossAxisCount: 3, children: const [
      ChildWidget(),
      ChildWidget(),
      ChildWidget(),
    ]);
  }
}

class ChildWidget extends StatelessWidget {
  const ChildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: generateError, child: const Text("Test"));
  }

  void generateError() async {
    Catcher.sendTestException();
  }
}
