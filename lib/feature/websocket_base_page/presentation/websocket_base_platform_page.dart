import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/message_processor.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/message_to_server.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/socket_message.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/websocket_handler.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/services/socket_message_processor.dart';

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
    IMessageProcessor<ISocketMessage<dynamic>, IMessageToServer> messageProcessor = SocketMessageProcessor();
    _socketHandler = IWebSocketHandler.createClient('ws://127.0.0.1:42627/websocket', messageProcessor);
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
        body: WebsocketBaseMockedScreen(
          socketHandler: _socketHandler,
        ),
      );
} // _WebsocketBasePlatformPageState
