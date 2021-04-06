import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';

/// Show the PageRoute based on the current device design
class DevicePage extends Page {
  final bool maintainState;
  final bool fullscreenDialog;
  final WidgetBuilder builder;

  DevicePage({
    Key key,
    String name,
    this.maintainState = true,
    this.fullscreenDialog = false,
    @required this.builder,
  }) : super(key: key, name: name);

  @override
  Route createRoute(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoPageRoute(
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          builder: builder,
          settings: this,
        );
      default:
        return MaterialPageRoute(
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          builder: builder,
          settings: this,
        );
    }
  }
}
