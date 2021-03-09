// import 'package:flutter/widgets.dart';
// import 'package:provider/provider.dart';
//
// abstract class StatePage<TPage extends StatePage<TPage>> {
//   const StatePage();
//
//   TPage toPrevious([bool isFirst = true]);
// }
//
// abstract class NodeStatePage<TNodePage extends StatePage<TNodePage>>
//     implements StatePage<TNodePage> {
//   List<StatePage> get pages;
//   int get currentPage;
//
//   TNodePage copyWith({int currentPage});
// }
//
// abstract class StateRouterDelegate extends RouterDelegate<List<Object>> with ChangeNotifier {
//   List<_MainStateNavigatorState> _navigators = [];
//
//   @override
//   List<Object> get currentConfiguration => _navigators.map((e) => e.state).toList();
//
//   void addNavigator(_MainStateNavigatorState navigator) {
//     navigator.addListener(_listenNavigator);
//     _navigators.add(navigator);
//   }
//
//   void removeNavigator(_MainStateNavigatorState navigator) {
//     navigator.removeListener(_listenNavigator);
//     _navigators.remove(navigator);
//   }
//
//   void _listenNavigator() {
//     notifyListeners();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<StateRouterDelegate>.value(
//       value: this,
//       child: buildNavigator(context),
//     );
//   }
//
//   Widget buildNavigator(BuildContext context);
//
//   @override
//   Future<bool> popRoute() async {
//     print('popRoute');
//     // return false;
//     for (final navigator in _navigators.reversed) {
//       if (await navigator._navigatorKey.currentState.maybePop()) return true;
//     }
//     return false;
//   }
//
//   @override
//   Future<void> setNewRoutePath(configuration) async {}
// }
//
// abstract class Master<TPage extends StatePage<TPage>> implements Listenable {
//   TPage get state;
//   set state(TPage state);
//
//   void goTo<TCurrentPage extends TPage>(TPage Function(TCurrentPage page) updater);
//
//   bool goToPreviousPage();
//
//   static Master<TPage> of<TPage extends StatePage<TPage>>(BuildContext context) {
//     return context.read<Master<TPage>>();
//   }
// }
//
// class MainStateNavigator<TPage extends StatePage<TPage>> extends StatefulWidget {
//   final TPage initialPage;
//   final List<Page> Function(BuildContext context, TPage info) pagesBuilder;
//
//   const MainStateNavigator({
//     Key key,
//     @required this.initialPage,
//     @required this.pagesBuilder,
//   }) : super(key: key);
//
//   @override
//   _MainStateNavigatorState<TPage> createState() => _MainStateNavigatorState<TPage>();
//
//   static _MainStateNavigatorState<TPage> of<TPage extends StatePage<TPage>>(BuildContext context) {
//     return context.findAncestorStateOfType<_MainStateNavigatorState<TPage>>();
//   }
// }
//
// class _MainStateNavigatorState<TPage extends StatePage<TPage>>
//     extends State<MainStateNavigator<TPage>> implements Listenable {
//   StateRouterDelegate _router;
//   final _navigatorKey = GlobalKey<NavigatorState>();
//
//   ValueNotifier<TPage> _page;
//   TPage get state => _page.value;
//   set state(TPage newPage) {
//     _page.value = newPage;
//   }
//
//   void goTo<TCurrentPage extends TPage>(TPage Function(TCurrentPage page) updater) {
//     final currentPage = state;
//     if (currentPage is TCurrentPage) {
//       state = updater(currentPage);
//     }
//   }
//
//   void goToPreviousPage() {
//     state = state.toPrevious();
//   }
//
//   @override
//   void addListener(void Function() listener) {
//     _page.addListener(listener);
//   }
//
//   @override
//   void removeListener(void Function() listener) {
//     _page.removeListener(listener);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _page = ValueNotifier(widget.initialPage);
//     _router = context.read<StateRouterDelegate>()..addNavigator(this);
//   }
//
//   @override
//   void dispose() {
//     _router.removeNavigator(this);
//     _page.dispose();
//     _page = null;
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (context) => Navigator(
//         key: _navigatorKey,
//         onPopPage: (route, result) {
//           print('$state');
//           if (!route.didPop(result)) return false;
//           goToPreviousPage();
//           return true;
//         },
//         pages: widget.pagesBuilder(context, state),
//       ),
//     );
//   }
// }
//
// class NodeStateNavigator<TNodePage extends StatePage<TNodePage>, TPage extends StatePage<TPage>>
//     extends StatefulWidget {
//   final TPage Function(TNodePage nodePage) reader;
//   final TNodePage Function(TNodePage nodePage, TPage page) updater;
//   final List<Page> Function(BuildContext context, TPage info) pagesBuilder;
//
//   const NodeStateNavigator({
//     Key key,
//     this.reader,
//     this.updater,
//     @required this.pagesBuilder,
//   }) : super(key: key);
//
//   @override
//   _NodeStateNavigatorState<TNodePage, TPage> createState() => _NodeStateNavigatorState();
// }
//
// class _NodeStateNavigatorState<TNodePage extends StatePage<TNodePage>, TPage extends StatePage<TPage>>
//     extends State<NodeStateNavigator<TNodePage, TPage>> implements Master<TPage> {
//   Master<TNodePage> _master;
//   final _navigatorKey = GlobalKey<NavigatorState>();
//
//   ValueNotifier<TPage> _state;
//   TPage get state => _state.value;
//   set state(TPage newPage) {
//     _state.value = newPage;
//   }
//
//   bool goTo<TCurrentPage extends TPage>(TPage Function(TCurrentPage page) updater) {
//     final currentPage = state;
//     if (currentPage is TCurrentPage) {
//       _master.state = widget.updater(_master.state, updater(currentPage));
//       return true;
//     }
//     return false;
//   }
//
//   bool goToPreviousPage() {
//     final previousState = state.toPrevious();
//     if (previousState == state) return _master.goToPreviousPage();
//     _master.state = widget.updater(_master.state, previousState);
//     return true;
//   }
//
//   void listenMaster() {
//     state = widget.reader(_master.state);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _master = context.read<Master<TNodePage>>();
//     _state = ValueNotifier(widget.reader(_master.state));
//     _master.addListener(listenMaster);
//   }
//
//   @override
//   void dispose() {
//     _master.removeListener(listenMaster);
//     _state.dispose();
//     _state = null;
//     super.dispose();
//   }
//
//   @override
//   void addListener(void Function() listener) => _state.addListener(listener);
//
//   @override
//   void removeListener(void Function() listener) => _state.removeListener(listener);
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Provider<Master<TPage>>.value(
//       value: this,
//       child: Builder(
//         builder: (context) => Navigator(
//           key: _navigatorKey,
//           onPopPage: (route, result) {
//             if (!route.didPop(result)) return false;
//             goToPreviousPage();
//             return true;
//           },
//           pages: widget.pagesBuilder(context, state),
//         ),
//       ),
//     );
//   }
// }
