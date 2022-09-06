import 'package:flutter/material.dart';
import '../../../../websocket_universal.dart';

import 'websocket_base_screen.dart';

/// WebsocketBasePlatformPage
class WebsocketBasePlatformPage extends StatefulWidget {
  const WebsocketBasePlatformPage({
    Key? key,
  }) : super(key: key);

  static PageRoute getRoute() => PageRouteBuilder(
        pageBuilder: (_, a1, a2) => const WebsocketBasePlatformPage(),
        settings: const RouteSettings(name: '/websocket-base-platform'),
        barrierColor: Colors.teal,
        transitionsBuilder: (context, a1, a2, child) {
          return FadeTransition(
            opacity: a1,
            child: child,
          );
        },
      );

  @override
  State<WebsocketBasePlatformPage> createState() => _WebsocketBasePlatformPageState();
} // WebsocketBasePlatformPage

/// State for widget WebsocketBasePlatformPage
class _WebsocketBasePlatformPageState extends State<WebsocketBasePlatformPage> {
  late final IWebSocketHandler<ISocketMessage<dynamic>, IMessageToServer> _socketHandler;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    final IMessageProcessor<ISocketMessage<dynamic>, IMessageToServer> messageProcessor = SocketMessageProcessor();
    //wss://ws.postman-echo.com/raw
    //ws://127.0.0.1:42627/websocket
    _socketHandler = IWebSocketHandler.createClient(
      'wss://ws.postman-echo.com/raw',
      messageProcessor,
    );
  }

  @override
  void didUpdateWidget(WebsocketBasePlatformPage oldWidget) {
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
    _socketHandler.close();
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('WebSocket base PLATFORM'),
        ),
        body: WebsocketBaseScreen(
          socketHandler: _socketHandler,
        ),
      );
} // _WebsocketBasePlatformPageState
