import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';

/// Show the PageRoute based on the current device design
class DevicePage extends Page {
  final WidgetBuilder builder;

  DevicePage({
    String name,
    @required this.builder,
  }) : super(key: ValueKey(name), name: name);

  @override
  Route createRoute(BuildContext context) {
    switch (TargetPlatform.iOS) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoPageRoute(builder: builder, settings: this);
      default:
        return MaterialPageRoute(builder: builder, settings: this);
    }
  }
}
