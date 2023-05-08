import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  var catcher = Catcher(rootWidget: const MyApp(), ensureInitialized: true);
  Directory? externalDir;
  if (Platform.isAndroid || Platform.isIOS) {
    externalDir = await getExternalStorageDirectory();
  }
  if (Platform.isMacOS) {
    externalDir = await getApplicationDocumentsDirectory();
  }
  String path = "";
  if (externalDir != null) {
    path = "${externalDir.path}/log.txt";
  }
  CatcherLogger.fine("PATH: $path");

  CatcherOptions debugOptions = CatcherOptions(
      DialogReportMode(), [FileHandler(File(path), printLogs: true)]);
  CatcherOptions releaseOptions =
      CatcherOptions(DialogReportMode(), [FileHandler(File(path))]);
  catcher.updateConfig(
      debugConfig: debugOptions, releaseConfig: releaseOptions);
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
        TextButton(
          onPressed: checkPermissions,
          child: const Text("Check permission"),
        ),
        TextButton(
          child: const Text("Generate error"),
          onPressed: () => generateError(),
        )
      ],
    );
  }

  void checkPermissions() async {
    var status = await Permission.storage.status;
    CatcherLogger.fine("Status: $status");
    if (!status.isGranted) {
      CatcherLogger.fine("Requested");
    }
  }

  void generateError() async {
    throw "Test exception";
  }
}
