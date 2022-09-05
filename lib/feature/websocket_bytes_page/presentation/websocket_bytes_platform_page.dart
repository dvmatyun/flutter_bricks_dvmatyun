import 'package:flutter/material.dart';
import '../../../../websocket_universal.dart';
import 'websocket_bytes_screen.dart';

/// WebsocketBytesPlatformPage
class WebsocketBytesPlatformPage extends StatefulWidget {
  const WebsocketBytesPlatformPage({
    Key? key,
  }) : super(key: key);

  static PageRoute getRoute() => PageRouteBuilder(
        pageBuilder: (_, a1, a2) => const WebsocketBytesPlatformPage(),
        settings: const RouteSettings(name: '/websocket-bytes-platform'),
        barrierColor: Colors.teal,
        transitionsBuilder: (context, a1, a2, child) {
          return FadeTransition(
            opacity: a1,
            child: child,
          );
        },
      );

  @override
  State<WebsocketBytesPlatformPage> createState() => _WebsocketBytesPlatformPageState();
} // WebsocketBytesPlatformPage

/// State for widget WebsocketBytesPlatformPage
class _WebsocketBytesPlatformPageState extends State<WebsocketBytesPlatformPage> {
  late final IWebSocketHandler<List<int>, List<int>> _socketHandler;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    final IMessageProcessor<List<int>, List<int>> messageProcessor = SocketSimpleBytesProcessor();
    //wss://ws.postman-echo.com/raw
    //ws://127.0.0.1:42627/websocket
    _socketHandler = IWebSocketHandler.createClient(
      'ws://127.0.0.1:42627/websocket',
      messageProcessor,
      skipPingMessages: false,
    );
  }

  @override
  void didUpdateWidget(WebsocketBytesPlatformPage oldWidget) {
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
          title: const Text('WebSocket bytes PLATFORM'),
        ),
        body: WebsocketBytesScreen(
          socketHandler: _socketHandler,
        ),
      );
} // _WebsocketBytesPlatformPageState
