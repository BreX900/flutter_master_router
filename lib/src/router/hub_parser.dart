import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
