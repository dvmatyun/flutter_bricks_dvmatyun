import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/feature/sliding_notification/presentation/sliding_notification_page.dart';
import 'package:flutter_bricks_dvmatyun/feature/websocket_base_page/presentation/websocket_base_mocked_page.dart';

/// HomePage
class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  static PageRoute getRoute() => PageRouteBuilder(
        pageBuilder: (_, a1, a2) => const HomePage(),
        settings: const RouteSettings(name: '/home'),
        barrierColor: Colors.teal,
        transitionsBuilder: (context, a1, a2, child) {
          return FadeTransition(
            opacity: a1,
            child: child,
          );
        },
      );

  @override
  State<HomePage> createState() => _HomePageState();
} // HomePage

/// State for widget HomePage
class _HomePageState extends State<HomePage> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Первичная инициализация виджета
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Конфигурация виджета изменилась
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Изменилась конфигурация InheritedWidget'ов
    // Также вызывается после initState, но до build'а
  }

  @override
  void dispose() {
    // Перманетное удаление стейта из дерева
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(SlidingNotificationPage.getRoute());
                },
                child: const Text('To sliding notifications page'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(WebsocketBaseMockedPagePage.getRoute());
                },
                child: const Text('To websocket mocked page'),
              ),
            ],
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
} // _HomePageState
