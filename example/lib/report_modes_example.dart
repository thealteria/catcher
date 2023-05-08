import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';

void main() {
  //silent:
  //ReportMode reportMode = SilentReportMode();

  //notification:
  //ReportMode reportMode = NotificationReportMode();

  //dialog:
  /*ReportMode reportMode = DialogReportMode(
      titleText: "Crash",
      descriptionText: "My description",
      acceptText: "OK",
      cancelText: "Back");*/

  //page:
  ReportMode reportMode = PageReportMode(showStackTrace: false);

  CatcherOptions debugOptions = CatcherOptions(reportMode, [ConsoleHandler()]);

  Catcher(rootWidget: const MyApp(), debugConfig: debugOptions);
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
    throw "Test exception";
  }
}
