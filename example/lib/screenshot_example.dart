import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  var catcher = Catcher(rootWidget: MyApp(), ensureInitialized: true);
  Directory? externalDir;
  if (Platform.isAndroid) {
    externalDir = await getExternalStorageDirectory();
  }
  if (Platform.isIOS) {
    externalDir = await getApplicationDocumentsDirectory();
  }
  String path = "";
  if (externalDir != null) {
    path = externalDir.path.toString();
  }

  CatcherOptions debugOptions = CatcherOptions(
    DialogReportMode(),
    [
      HttpHandler(HttpRequestType.post,
          Uri.parse("https://jsonplaceholder.typicode.com/posts"),
          printLogs: true),
    ],
    customParameters: <String, dynamic>{
      "Test": "Test12345",
      "Test2": "Test54321"
    },
    screenshotsPath: path,
  );

  catcher.updateConfig(debugConfig: debugOptions);
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
      navigatorKey: Catcher.navigatorKey,
      home: CatcherScreenshot(
        catcher: Catcher.getInstance(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: ChildWidget(),
        ),
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

  void generateError() async {
    Catcher.sendTestException();
  }
}
