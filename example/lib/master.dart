import 'package:flutter/widgets.dart';

//               N0A
//              /   \
//             /     \
//           N1A      \
//           /         \
//          /           \
//       N2A             N2B---------|-|-|
//                      /           /  |  \
//                     /           /   |   \
//                  N3A           /    |    \
//                               /     |     \
//                       N2B(N1A)  N2B2(N1B)  N2B3(N1C)
//                             /
//                            /
//                      N2B1(N2)

/// root of states
abstract class MasterState<TPage extends MasterState<TPage>> {
  const MasterState();

  TPage toPrevious([bool isFirst = true]);
}

abstract class MasterRouterDelegate<TPage extends MasterState<TPage>> extends RouterDelegate<TPage>
    with ChangeNotifier
    implements Master<TPage> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  TPage _state;
  TPage get state => _state;
  set state(TPage newPage) {
    if (_state == newPage) return;
    _state = newPage;
    notifyListeners();
  }

  MasterRouterDelegate(this._state);

  @override
  bool goTo<TCurrentPage extends TPage>(TPage Function(TCurrentPage page) updater) {
    final currentPage = state;
    if (currentPage is TCurrentPage) {
      state = updater(currentPage);
      return true;
    }
    return false;
  }

  @override
  bool goToPreviousPage() {
    final previousState = state.toPrevious();
    if (previousState == state) return false;
    state = previousState;
    return true;
  }

  @override
  TPage get currentConfiguration => state;

  /// if returns is false close app else nothing
  @override
  Future<bool> popRoute() async {
    print('popRoute');
    return goToPreviousPage();
  }

  @override
  Widget build(BuildContext context) {
    return MasterProvider<TPage>(
      master: this,
      child: Builder(
        builder: (context) {
          return Navigator(
            key: _navigatorKey,
            onPopPage: (route, result) {
              // print(
              //     'onPopPage nav: ${_navigatorKey.currentState.canPop()}, rout: ${route.didPop(result)}');
              // This is method is ignored
              // if (!route.didPop(result)) return false;
              // goToPreviousPage();
              print('onPopPage');

              route.willPop().then((value) {
                print('Hi');
                if (route.didPop(result)) {
                  goToPreviousPage();
                }
              });
              return false;
            },
            pages: buildPages(context, state),
          );
        },
      ),
    );
  }

  List<Page> buildPages(BuildContext context, TPage state);
}

abstract class Master<TPage extends MasterState<TPage>> {
  TPage get state;
  set state(TPage state);

  bool goTo<TCurrentPage extends TPage>(TPage Function(TCurrentPage page) updater);

  bool goToPreviousPage();
}

class MasterNavigator<TNodePage extends MasterState<TNodePage>, TPage extends MasterState<TPage>>
    extends StatefulWidget {
  final TPage Function(TNodePage nodePage) reader;
  final TNodePage Function(TNodePage nodePage, TPage page) updater;
  final List<Page> Function(BuildContext context, TPage info) pagesBuilder;

  const MasterNavigator({
    Key key,
    this.reader,
    this.updater,
    @required this.pagesBuilder,
  }) : super(key: key);

  @override
  _MasterNavigatorState<TNodePage, TPage> createState() => _MasterNavigatorState();
}

class _MasterNavigatorState<TNodePage extends MasterState<TNodePage>,
        TPage extends MasterState<TPage>> extends State<MasterNavigator<TNodePage, TPage>>
    implements Master<TPage> {
  Master<TNodePage> get _master => MasterProvider.of<TNodePage>(context);

  TPage get state => widget.reader(_master.state);
  set state(TPage newPage) {
    _master.state = widget.updater(_master.state, newPage);
  }

  bool goTo<TCurrentPage extends TPage>(TPage Function(TCurrentPage page) updater) {
    final currentPage = state;
    if (currentPage is TCurrentPage) {
      state = updater(currentPage);
      return true;
    }
    return false;
  }

  bool goToPreviousPage() {
    final previousState = state.toPrevious();
    if (previousState == state) return _master.goToPreviousPage();
    state = previousState;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MasterProvider<TPage>(
      master: this,
      child: Builder(
        builder: (context) => Navigator(
          onPopPage: (route, result) {
            // This is method is ignored
            if (!route.didPop(result)) return false;
            goToPreviousPage();
            return true;
          },
          pages: widget.pagesBuilder(context, state),
        ),
      ),
    );
  }
}

class MasterProvider<TPage extends MasterState<TPage>> extends StatelessWidget {
  final Master<TPage> master;
  final Widget child;

  const MasterProvider({
    Key key,
    @required this.master,
    @required this.child,
  })  : assert(master != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => child;

  static Master<TPage> of<TPage extends MasterState<TPage>>(BuildContext context) {
    return context.findAncestorWidgetOfExactType<MasterProvider<TPage>>().master;
  }
}

extension MasterBuildContext on BuildContext {
  Master master<TMasterPage extends MasterState<TMasterPage>>() {
    return MasterProvider.of<TMasterPage>(this);
  }

  bool goTo<TMasterPage extends MasterState<TMasterPage>, TCurrentPage extends TMasterPage>(
    TMasterPage Function(TCurrentPage page) updater,
  ) {
    return master<TMasterPage>().goTo<TCurrentPage>(updater);
  }

  bool goToPreviousPage<TMasterPage extends MasterState<TMasterPage>>() {
    return master<TMasterPage>().goToPreviousPage();
  }
}

class BranchState {
  final int currentIndex;
  final List<MasterState<MasterState>> states;

  const BranchState({
    this.currentIndex = 0,
    @required this.states,
  });

  TMasterState of<TMasterState extends MasterState<TMasterState>>() {
    return states.firstWhere((state) => state is TMasterState) as TMasterState;
  }

  BranchState goTo(int currentIndex) {
    return BranchState(
      currentIndex: currentIndex ?? this.currentIndex,
      states: states,
    );
  }

  BranchState update<TMasterState extends MasterState<TMasterState>>(TMasterState currentState) {
    return BranchState(
      currentIndex: currentIndex,
      states: states.map((state) => state is TMasterState ? currentState : state).toList(),
    );
  }

  BranchState apply<TMasterState extends MasterState<TMasterState>>({
    int currentIndex,
    TMasterState currentState,
  }) {
    return BranchState(
      currentIndex: currentIndex ?? this.currentIndex,
      states: states.map((state) => state is TMasterState ? currentState : state).toList(),
    );
  }
}
