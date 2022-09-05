import 'package:flutter/material.dart';
import '../../../../websocket_universal.dart';

import 'websocket_base_screen.dart';

/// WebsocketBaseMockedPage
class WebsocketBaseMockedPage extends StatefulWidget {
  const WebsocketBaseMockedPage({
    Key? key,
  }) : super(key: key);

  static PageRoute getRoute() => PageRouteBuilder(
        pageBuilder: (_, a1, a2) => const WebsocketBaseMockedPage(),
        settings: const RouteSettings(name: '/websocket-base-mocked'),
        barrierColor: Colors.teal,
        transitionsBuilder: (context, a1, a2, child) {
          return FadeTransition(
            opacity: a1,
            child: child,
          );
        },
      );

  @override
  State<WebsocketBaseMockedPage> createState() => _WebsocketBaseMockedPageState();
} // WebsocketBaseMockedPage

/// State for widget WebsocketBaseMockedPage
class _WebsocketBaseMockedPageState extends State<WebsocketBaseMockedPage> {
  late final IWebSocketHandler<ISocketMessage<dynamic>, IMessageToServer> _socketHandler;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    IMessageProcessor<ISocketMessage<dynamic>, IMessageToServer> messageProcessor = SocketMessageProcessor();
    _socketHandler = IWebSocketHandler.createMockedWebsocketClient('mocked-url.com', messageProcessor);
  }

  @override
  void didUpdateWidget(WebsocketBaseMockedPage oldWidget) {
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
          title: const Text('WebSocket base MOCKED'),
        ),
        body: WebsocketBaseScreen(
          socketHandler: _socketHandler,
        ),
      );
} // _WebsocketBaseMockedPageState
