import 'package:flutter/material.dart';

class CatcherErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? details;
  final bool showStacktrace;
  final String title;
  final String description;
  final double maxWidthForSmallMode;

  const CatcherErrorWidget({
    Key? key,
    this.details,
    required this.showStacktrace,
    required this.title,
    required this.description,
    required this.maxWidthForSmallMode,
  })  : assert(maxWidthForSmallMode > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraint) {
            if (constraint.maxWidth < maxWidthForSmallMode) {
              return _buildSmallErrorWidget();
            } else {
              return _buildNormalErrorWidget();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSmallErrorWidget() {
    return const Center(
      child: Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 40,
      ),
    );
  }

  Widget _buildNormalErrorWidget() {
    return Center(
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildIcon(),
          Text(
            title,
            style: const TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _getDescription(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildStackTraceWidget()
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return const Icon(
      Icons.announcement,
      color: Colors.red,
      size: 40,
    );
  }

  Widget _buildStackTraceWidget() {
    if (showStacktrace && details != null) {
      return Text(
        'Error: ${details!.exception.toString()}\n\nStackTrace:${details!.stack.toString()}',
      );
    }

    return const SizedBox.shrink();
  }

  String _getDescription() {
    String descriptionText = description;
    if (showStacktrace) {
      descriptionText += " See details below.";
    }
    return descriptionText;
  }
}
