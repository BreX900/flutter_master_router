import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hub_router/src/internal_utils.dart';
import 'package:hub_router/src/router/hub_location.dart';

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
  List<HubLocation> _history;

  List<HubLocation> get history => List.unmodifiable(_history);

  HubLocation get currentLocation => _history.last;

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  HubDelegate({
    @required HubLocation initialLocation,
    List<HubLocation> locations,
  })  : _locations = List.unmodifiable(locations ?? []),
        _history = [initialLocation];

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
  Future<void> setNewRoutePath(Uri newUri) => SynchronousFuture(null);

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
  final uri = ValueNotifier(Uri.parse('/'));

  HubRouterDelegate({
    @required HubLocation initialLocation,
    List<HubLocation> locations,
  }) : super(
          initialLocation: initialLocation,
          locations: locations,
        );

  @override
  Uri get currentConfiguration => Uri.parse(currentLocation.bluePath);

  @override
  Future<void> setNewRoutePath(Uri newUri) {
    // When user press back in web the uri is the back navigation flow
    HubLog.i.info('HubDelegate.setNewRoutePath($uri)');
    uri.value = newUri;
    return super.setNewRoutePath(newUri);
  }

  static HubRouterDelegate of(BuildContext context) {
    return Router.of(context).routerDelegate as HubRouterDelegate;
  }
}
