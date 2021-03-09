import 'package:equatable/equatable.dart';
import 'package:example/master.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class AppMasterState extends MasterState<AppMasterState> with EquatableMixin {
  @override
  AppMasterState toPrevious([bool isFirst = true]) {
    return this;
  }

  AppMasterState toUnauthWelcome() => WelcomeNodeState();

  AppMasterState toAuthHome() {
    return HomeNodeState(
      productListState: ProductListMasterState(),
      homeState: HomeMasterState(),
      infoState: InfoMasterState(),
      currentState: 0,
    );
  }

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class WelcomeNodeState extends AppMasterState {
  @override
  AppMasterState toPrevious([bool isFirst = true]) => toUnauthWelcome();

  AppMasterState toUnauthSignIn() => SignInNodeState();
}

class SignInNodeState extends WelcomeNodeState {
  @override
  AppMasterState toPrevious([bool isFirst = true]) {
    return isFirst ? super.toPrevious(false) : toUnauthSignIn();
  }
}

class HomeNodeState extends AppMasterState {
  final int currentState;
  final List<MasterState<MasterState>> states;

  final ProductListMasterState productListState;
  final HomeMasterState homeState;
  final InfoMasterState infoState;

  HomeNodeState({
    @required this.productListState,
    @required this.homeState,
    @required this.infoState,
    @required this.currentState,
  }) : states = [productListState, homeState, infoState];

  HomeNodeState.from(HomeNodeState state)
      : this(
          productListState: state.productListState,
          homeState: state.homeState,
          infoState: state.infoState,
          currentState: state.currentState,
        );

  @override
  AppMasterState toPrevious([bool isFirst = true]) {
    if (!isFirst) return toAuthHome();
    switch (currentState) {
      case 0:
        return changeHomeTab(productListState: productListState.toPrevious(isFirst));
      case 1:
        return changeHomeTab(homeState: homeState.toPrevious(isFirst));
      case 2:
        return changeHomeTab(infoState: infoState.toPrevious(isFirst));
    }
    return this;
  }

  AppMasterState toAuthHome() {
    return HomeNodeState(
      productListState: productListState,
      homeState: homeState,
      infoState: infoState,
      currentState: 0,
    );
  }

  AppMasterState toAuthSetting() => SettingNodeState(this);

  AppMasterState changeHomeTab({
    ProductListMasterState productListState,
    HomeMasterState homeState,
    InfoMasterState infoState,
    int currentState,
  }) {
    return HomeNodeState(
      productListState: productListState ?? this.productListState,
      homeState: homeState ?? this.homeState,
      infoState: infoState ?? this.infoState,
      currentState: currentState ?? this.currentState,
    );
  }

  @override
  List<Object> get props => [currentState, ...states];
}

class ProductListMasterState extends MasterState<ProductListMasterState> with EquatableMixin {
  @override
  ProductListMasterState toPrevious([bool isFirst = true]) => toProduct();

  ProductListMasterState toProduct() => ProductNodeState();

  @override
  List<Object> get props => [];
}

class ProductNodeState extends ProductListMasterState {
  @override
  ProductListMasterState toPrevious([bool isFirst = true]) {
    return isFirst ? super.toPrevious(false) : toProduct();
  }
}

class HomeMasterState extends MasterState<HomeMasterState> with EquatableMixin {
  @override
  HomeMasterState toPrevious([bool isFirst = true]) => HomeMasterState();

  @override
  List<Object> get props => [];
}

class InfoMasterState extends MasterState<InfoMasterState> with EquatableMixin {
  @override
  InfoMasterState toPrevious([bool isFirst = true]) => toMoreInfo();

  InfoMasterState toMoreInfo() => MoreInfoMasterState();

  @override
  List<Object> get props => [];
}

class MoreInfoMasterState extends InfoMasterState {
  @override
  InfoMasterState toPrevious([bool isFirst = true]) {
    return isFirst ? super.toPrevious(false) : toMoreInfo();
  }

  @override
  List<Object> get props => [];
}

class SettingNodeState extends HomeNodeState {
  SettingNodeState(HomeNodeState state) : super.from(state);

  @override
  HomeNodeState toPrevious([bool isFirst = true]) {
    return isFirst ? super.toPrevious(false) : toAuthSetting();
  }
}

class MyRouterDelegate extends MasterRouterDelegate<AppMasterState> {
  MyRouterDelegate() : super(SignInNodeState());

  @override
  Future<void> setNewRoutePath(AppMasterState configuration) async {
    print('configuration: $configuration');
  }

  List<Page> buildPages(BuildContext context, AppMasterState state) {
    return [
      if (state is WelcomeNodeState) ...[
        MaterialPage(
          child: FakeScreen(
            debugLabel: 'First Welcome Page',
            onTap: () => context.goTo<AppMasterState, WelcomeNodeState>((it) => it.toAuthHome()),
            color: Colors.lightBlue,
          ),
        ),
        if (state is SignInNodeState) ...[
          MaterialPage(
            child: Builder(
              builder: (context) => WillPopScope(
                onWillPop: () async {
                  print('Pop?');
                  return false;
                },
                child: FakeScreen(
                  debugLabel: 'Second Welcome Page',
                  onTap: () => Navigator.pop(context),
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ] else if (state is HomeNodeState) ...[
        MaterialPage(
          child: HomeScreen(),
        ),
        if (state is SettingNodeState) ...[
          MaterialPage(
            child: FakeScreen(debugLabel: 'Settings'),
          ),
        ],
      ],
    ];
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigator = MasterProvider.of<AppMasterState>(context);
    final page = navigator.state as HomeNodeState;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => navigator.goTo<HomeNodeState>((pg) => pg.toAuthSetting()),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: IndexedStack(
        index: page.currentState,
        children: [
          MasterNavigator<AppMasterState, ProductListMasterState>(
            reader: (nodePage) => page.productListState,
            updater: (nodePage, page) {
              return nodePage is HomeNodeState
                  ? nodePage.changeHomeTab(productListState: page)
                  : nodePage;
            },
            pagesBuilder: (context, page) {
              return [
                MaterialPage(
                  child: GestureDetector(
                    onTap: () {
                      context.goTo<ProductListMasterState, ProductListMasterState>((pg) {
                        return pg.toProduct();
                      });
                    },
                    child: Container(color: Colors.yellow),
                  ),
                ),
                if (page is ProductNodeState) ...[
                  MaterialPage(
                    child: FakeScreen(debugLabel: 'Product Tap\nSecondary Page'),
                  ),
                ],
              ];
            },
          ),
          MasterNavigator<AppMasterState, HomeMasterState>(
            reader: (nodePage) => page.homeState,
            updater: (nodePage, page) {
              return nodePage is HomeNodeState ? nodePage.changeHomeTab(homeState: page) : nodePage;
            },
            pagesBuilder: (context, page) {
              return [
                MaterialPage(child: FakeScreen(debugLabel: 'Home Page')),
              ];
            },
          ),
          MasterNavigator<AppMasterState, InfoMasterState>(
            reader: (nodePage) => page.infoState,
            updater: (nodePage, page) {
              return nodePage is HomeNodeState ? nodePage.changeHomeTab(infoState: page) : nodePage;
            },
            pagesBuilder: (context, state) {
              return [
                MaterialPage(
                  child: FakeScreen(
                    debugLabel: 'Info Page',
                    onTap: () =>
                        context.goTo<InfoMasterState, InfoMasterState>((pg) => pg.toMoreInfo()),
                  ),
                ),
                if (state is MoreInfoMasterState) ...[
                  MaterialPage(child: FakeScreen(debugLabel: 'More Info PAge')),
                ],
              ];
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: page.currentState,
        onTap: (index) =>
            navigator.goTo<HomeNodeState>((pg) => pg.changeHomeTab(currentState: index)),
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
  final Color color;

  const FakeScreen({
    Key key,
    @required this.debugLabel,
    this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: color ?? Colors.blue,
        child: Center(
          child: Text(debugLabel),
        ),
      ),
    );
  }
}
