import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hub_router/hub_router.dart';

class WelcomeLocation extends HubLocation {
  @override
  String get pathBluePrint => '/out';

  @override
  Page buildPage(BuildContext context) {
    return DevicePage(
      name: pathBluePrint,
      builder: (context) => FakeScreen(
        debugLabel: 'Welcome',
        onTap: () => context.hub.push(SignInLocation()),
        onSecondaryTap: () => context.hub.replaceAll([HomeLocation()]),
        color: Colors.lightBlue,
      ),
    );
  }
}

class SignInLocation extends HubLocation {
  @override
  String get pathBluePrint => '/out/signIn';

  @override
  Page buildPage(BuildContext context) {
    return DevicePage(
      name: pathBluePrint,
      builder: (context) => FakeScreen(
        debugLabel: 'Welcome->SignIn',
        onTap: () => context.hub.replaceAll([HomeLocation()]),
        onSecondaryTap: () => context.hub.pop(),
        color: Colors.blue,
      ),
    );
  }
}

class HomeLocation extends HubLocation {
  @override
  String get pathBluePrint => '/in';

  @override
  Page buildPage(BuildContext context) {
    return DevicePage(
      name: pathBluePrint,
      builder: (context) => HomeScreen(),
    );
  }
}

class SettingsLocation extends HubLocation {
  @override
  String get pathBluePrint => '/in/settings';

  @override
  Page buildPage(BuildContext context) {
    return DevicePage(
      name: pathBluePrint,
      builder: (context) => FakeScreen(debugLabel: 'Home->Settings'),
    );
  }
}

class ProductsListLocation extends HubLocation {
  @override
  String get pathBluePrint => '/in/products';

  @override
  Page buildPage(BuildContext context) {
    return DevicePage(
      name: pathBluePrint,
      builder: (context) => FakeScreen(
        debugLabel: 'Home\nProducts',
        onTap: () => context.hub.push(ProductLocation()),
        color: Colors.green,
      ),
    );
  }
}

class ProductLocation extends HubLocation {
  @override
  String get pathBluePrint => '/in/products/:idProduct|';

  @override
  Page buildPage(BuildContext context) {
    return DevicePage(
      name: pathBluePrint,
      builder: (context) => FakeScreen(debugLabel: 'Home\nProducts\nProduct'),
    );
  }
}

class DashboardLocation extends HubLocation {
  @override
  String get pathBluePrint => '/in/dashboard';

  @override
  Page buildPage(BuildContext context) {
    return DevicePage(
      name: pathBluePrint,
      builder: (context) => FakeScreen(debugLabel: 'Home\nDashboard', color: Colors.white),
    );
  }
}

class InfoLocation extends HubLocation {
  @override
  String get pathBluePrint => '/in/info';

  @override
  Page buildPage(BuildContext context) {
    return DevicePage(
      name: pathBluePrint,
      builder: (context) => FakeScreen(debugLabel: 'Home\nInfo'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productsHub = HubDelegate(
    locations: [ProductsListLocation()],
  );
  final _homeHub = HubDelegate(
    locations: [DashboardLocation()],
  );
  final _infoHub = HubDelegate(
    locations: [InfoLocation()],
  );

  int _currentIndex = 0;

  void onTapNavigationBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => context.hub.push(SettingsLocation()),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: StackHub(
        index: _currentIndex,
        hubDelegates: [
          _productsHub,
          _homeHub,
          _infoHub,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTapNavigationBar,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.extension),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}

class FakeScreen extends StatelessWidget {
  final String debugLabel;
  final VoidCallback onTap;
  final VoidCallback onSecondaryTap;
  final Color color;

  const FakeScreen({
    Key key,
    @required this.debugLabel,
    this.onTap,
    this.onSecondaryTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color ?? Colors.blue,
      appBar: AppBar(
        title: GestureDetector(
          onTap: onSecondaryTap,
          child: Text('Secondary action'),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: GestureDetector(
          onTap: onTap,
          child: Center(
            child: Text(debugLabel),
          ),
        ),
      ),
    );
  }
}
