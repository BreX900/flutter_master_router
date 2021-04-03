import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';

class HubLocationData {
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  const HubLocationData({
    this.pathParameters = const <String, String>{},
    this.queryParameters = const <String, String>{},
  });

  HubLocationData clone() {
    return HubLocationData(
      pathParameters: Map.of(pathParameters),
      queryParameters: Map.of(queryParameters),
    );
  }

  HubLocationData copyWith({
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
  }) {
    return HubLocationData(
      pathParameters: pathParameters ?? this.pathParameters,
      queryParameters: queryParameters ?? this.queryParameters,
    );
  }
}

abstract class HubLocation {
  /// Ex. /products/:productId/*
  /// ':' Replace it with value. The values is saved in queryParameters
  /// '*' Accept all segments after this keyword
  String get bluePath;

  Widget buildHub(BuildContext context, Widget child) => child;

  Page buildPage(BuildContext context);

  HubLocation setData(HubLocationData data) => this;
  HubLocationData getData() => HubLocationData();

  @override
  String toString() => '$runtimeType(bluePath:$bluePath)';
}

class HubLocationEntry {
  final HubLocation location;
  final HubLocationData data;

  HubLocationEntry(this.location, this.data);
}

/// Main navigation hub methods
abstract class Hub {
  Hub._();

  /// Add location
  void push(HubLocation location);

  /// Remove current location
  /// If it has only one location the entire app to be popped
  HubLocation pop();

  /// Remove current location
  /// Returns the popped location when have more than one location
  HubLocation maybePop();

  /// Replace current location with new location
  /// Returns the replaced current location
  HubLocation replace(HubLocation location);

  /// Replace the current locations with new locations
  /// Returns the replaced current locations
  List<HubLocation> replaceAll(List<HubLocation> locations);
}

class HubDelegate extends RouterDelegate<Uri>
    with PopNavigatorRouterDelegateMixin, ChangeNotifier
    implements Hub {
  final List<HubLocation> _locations;
  var _history = List<HubLocation>();

  List<HubLocation> get history => _history.toList();

  HubLocation get currentLocation => _history.last;

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  HubDelegate({
    HubLocation initialLocation,
    @required List<HubLocation> locations,
  }) : _locations = locations {
    _history.add(initialLocation ?? _locations.first);
  }

  @override
  Widget build(BuildContext context) {
    // build a pages based on history locations
    final pages = history.map((entry) {
      return entry.buildPage(context);
    }).toList();

    HubLog.i.info('history $_history | pages $pages');

    final Widget current = Navigator(
      key: navigatorKey,
      pages: pages,
      // It is called:
      // - after RouterDelegate.popRoute method
      // - Back CupertinoPageRoute animation
      // - Navigator.pop method
      onPopPage: (route, result) {
        final canPop = route.didPop(result);
        HubLog.i.info('Navigator.onPopPage($route,$result):$canPop');
        if (!canPop) return false;

        HubLog.i.info('Navigator.onPopPage():Popped');
        final poppedLocation = maybePop();
        return poppedLocation != null;
      },
    );

    return history.fold(current, (child, location) => location.buildHub(context, child));
  }

  @override
  Future<void> setNewRoutePath(Uri uri) => SynchronousFuture(null);

  /// Permit a deep navigation
  /// It is a delegated navigator
  HubDelegate _child;

  HubDelegate get child => child;

  void assignChild(HubDelegate child) {
    assert(_child == null || _child == child, "You cannot assign more than one child to a father");
    _child = child;
  }

  void changeChild(HubDelegate oldChild, HubDelegate newChild) {
    assert(_child == null || _child == oldChild,
        "You can't change the child if you don't know the child she has now");
    _child = newChild;
  }

  void revokeChild(HubDelegate oldChild) {
    assert(_child == null || _child == oldChild,
        "You cannot revoke a child that you are unaware of its existence");
    _child = null;
  }

  // It is called when user press back button on android.
  // It call [Navigator.onPopPage]
  // true When you can pop a page
  // Returning false will cause the entire app to be popped.
  @override
  Future<bool> popRoute() async {
    HubLog.i.info('$this.popRoute()');
    // if it has a child delegate to pop a route page
    if (_child != null) {
      final canPop = await _child.popRoute();
      HubLog.i.info('HubDelegate.popRoute():_child.$canPop');

      // if a child can pop returns a child pop result
      if (canPop) return canPop;
      // otherwise continue a popping in this router
    }
    final canPop = await super.popRoute();
    HubLog.i.info('HubDelegate.popRoute():$canPop');
    return canPop;
  }

  @deprecated
  void goTo(HubLocation location) {
    final bluePath = location.bluePath;

    // find locations for arrive a location
    Iterable<HubLocation> locations = _locations;
    final blueSegments = bluePath.split('/').where((s) => s.trim().isNotEmpty);
    String currentBlueSegment = '';
    for (final blueSegment in blueSegments) {
      currentBlueSegment = '$currentBlueSegment/$blueSegment';
      locations = locations.where((l) => l.bluePath.startsWith(currentBlueSegment));
    }
    locations = locations.where((element) => element.bluePath.length <= bluePath.length).toList();

    // generate data from location

    notifyListeners();
  }

  /// [Hub.push]
  void push(HubLocation location) {
    _history.add(location);
    notifyListeners();
  }

  /// [Hub.pop]
  HubLocation pop() {
    final poppedLocation = _history.removeLast();
    notifyListeners();
    return poppedLocation;
  }

  /// [Hub.maybePop]
  HubLocation maybePop() {
    if (_history.length > 1) {
      final poppedLocation = _history.removeLast();
      notifyListeners();
      return poppedLocation;
    } else {
      return null;
    }
  }

  /// [Hub.replace]
  HubLocation replace(HubLocation location) {
    final poppedLocation = _history.removeLast();
    _history.add(location);
    notifyListeners();
    return poppedLocation;
  }

  /// [Hub.replaceAll]
  List<HubLocation> replaceAll(List<HubLocation> locations) {
    final poppedHistory = _history;
    _history = locations.toList();
    notifyListeners();
    return poppedHistory;
  }

  static HubDelegate of(BuildContext context) {
    return Router.of(context).routerDelegate as HubDelegate;
  }

  @override
  String toString() => 'HubDelegate{history:$history,child:${_child != null}}';
}

class HubRouterDelegate extends HubDelegate {
  @override
  Uri get currentConfiguration => Uri.parse(currentLocation.bluePath);

  @override
  Future<void> setNewRoutePath(Uri uri) {
    // When user press back in web the uri is the back navigation flow
    HubLog.i.info('HubDelegate.setNewRoutePath($uri)');
    return SynchronousFuture(null);
  }
}

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

extension Ext on BuildContext {
  Hub get hub => HubDelegate.of(this);
}

class HubRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  SynchronousFuture<Uri> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(Uri.parse(routeInformation.location));
  }

  @override
  RouteInformation restoreRouteInformation(Uri uri) {
    return RouteInformation(location: uri.toString());
  }
}

class HubLog {
  static bool isEnabled = true;

  HubLog._();

  static final HubLog instance = HubLog._();

  static HubLog get i => instance;

  void log(Object message) {
    if (isEnabled) print(message);
  }

  void info(Object message) {
    if (isEnabled) print(message);
  }
}
