import 'package:example/test.dart';
import 'package:flutter/material.dart';
import 'package:hub_router/hub_router.dart';

void main() {
  runApp(MyApp());
}

class XRouteInformationParser extends RouteInformationParser<dynamic> {
  @override
  RouteInformation restoreRouteInformation(dynamic configuration) {
    return RouteInformation(location: '/');
  }

  @override
  Future<dynamic> parseRouteInformation(RouteInformation routeInformation) async {
    return null;
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final parser = HubRouteInformationParser();
  final delegate = HubRouterDelegate(locations: [WelcomeLocation()]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(),
      routeInformationParser: parser,
      routerDelegate: delegate,
    );
  }
}
