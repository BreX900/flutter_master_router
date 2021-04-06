import 'package:flutter/material.dart';
import 'package:hub_router/src/internal_utils.dart';
import 'package:hub_router/src/router/hub_router.dart';

/// Permit a deep navigation with multiple navigations
class StackHub extends StatefulWidget {
  final int index;
  final List<HubDelegate> hubDelegates;

  const StackHub({
    Key key,
    @required this.index,
    @required this.hubDelegates,
  }) : super(key: key);

  HubDelegate get currentHubDelegate => hubDelegates[index];

  @override
  _StackHubState createState() => _StackHubState();
}

class _StackHubState extends State<StackHub> {
  HubDelegate _father;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newFather = HubDelegate.of(context);
    if (_father != newFather) {
      _father?.revokeChild(widget.currentHubDelegate);
      _father = newFather;
      _father.assignChild(widget.currentHubDelegate);
    }
  }

  @override
  void didUpdateWidget(covariant StackHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _father.changeChild(oldWidget.currentHubDelegate, widget.currentHubDelegate);
    }
  }

  @override
  void dispose() {
    _father.revokeChild(widget.currentHubDelegate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: widget.hubDelegates.map((hubDelegate) {
        return Router(
          routerDelegate: hubDelegate,
          backButtonDispatcher: HubBackButtonDispatcher(),
        );
      }).toList(),
    );
  }
}

class HubBackButtonDispatcher extends BackButtonDispatcher {
  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    HubLog.i.info('HubBackButtonDispatcher.invokeCallback()');
    await Future.delayed(Duration(seconds: 5));
    final canPop = await super.invokeCallback(defaultValue);
    return canPop;
  }
}
