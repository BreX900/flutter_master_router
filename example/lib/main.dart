import 'package:example/master.dart';
import 'package:example/test.dart';
import 'package:flutter/material.dart';

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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final parser = HubRouteInformationParser();
  final delegate = HubDelegate(
    locations: [
      WelcomeLocation(),
      SignInLocation(),
      HomeLocation(),
    ],
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<bool> didPopRoute() {
    print('Popped');
    return super.didPopRoute();
  }

  @override
  Future<bool> didPushRoute(String route) {
    print(route);
    return super.didPushRoute(route);
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    print('${routeInformation.location} - ${routeInformation.state}');
    return super.didPushRouteInformation(routeInformation);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(),
      routeInformationParser: parser,
      routerDelegate: delegate,
      // routeInformationProvider: PlatformRouteInformationProvider(
      //   initialRouteInformation: RouteInformation(location: '/'),
      // ),
      // backButtonDispatcher: HubBackButtonDispatcher(),
    );
  }
}
