import 'package:flutter/widgets.dart';
import 'package:hub_router/src/router/hub_router.dart';

/// Permit a deep navigation
class InjectHub extends StatefulWidget {
  final HubDelegate hubDelegate;

  const InjectHub({Key key, @required this.hubDelegate}) : super(key: key);

  @override
  _InjectHubState createState() => _InjectHubState();
}

class _InjectHubState extends State<InjectHub> {
  HubDelegate _father;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newFather = HubDelegate.of(context);
    if (_father != newFather) {
      _father.revokeChild(widget.hubDelegate);
      _father = newFather;
      _father.assignChild(widget.hubDelegate);
    }
  }

  @override
  void didUpdateWidget(covariant InjectHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hubDelegate != oldWidget.hubDelegate) {
      _father.changeChild(oldWidget.hubDelegate, widget.hubDelegate);
    }
  }

  @override
  void dispose() {
    _father.revokeChild(widget.hubDelegate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate: widget.hubDelegate,
    );
  }
}
