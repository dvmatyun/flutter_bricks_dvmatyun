import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/feature/sliding_notification/presentation/sliding_notification_screen.dart';

/// SlidingNotificationPage
class SlidingNotificationPage extends StatefulWidget {
  const SlidingNotificationPage({
    Key? key,
  }) : super(key: key);

  static PageRoute getRoute() => PageRouteBuilder(
        pageBuilder: (_, a1, a2) => const SlidingNotificationPage(),
        settings: const RouteSettings(name: '/sliding-notification'),
        barrierColor: Colors.teal,
        transitionsBuilder: (context, a1, a2, child) {
          return FadeTransition(
            opacity: a1,
            child: child,
          );
        },
      );

  @override
  State<SlidingNotificationPage> createState() => _SlidingNotificationPageState();
} // SlidingNotificationPage

/// State for widget SlidingNotificationPage
class _SlidingNotificationPageState extends State<SlidingNotificationPage> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Первичная инициализация виджета
  }

  @override
  void didUpdateWidget(SlidingNotificationPage oldWidget) {
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
          title: const Text('Sliding notifications'),
        ),
        body: const SlidingNotificationScreen(),
      );
} // _SlidingNotificationPageState
