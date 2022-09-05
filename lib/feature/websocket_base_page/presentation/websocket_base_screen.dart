import 'package:flutter/material.dart';
import '../../../../websocket_universal.dart';

import 'widgets/socket_base_data_listener.dart';
import 'widgets/socket_basic_controls.dart';
import 'widgets/socket_current_status.dart';

/// WebsocketBaseMockedScreen
class WebsocketBaseScreen extends StatefulWidget {
  const WebsocketBaseScreen({
    required this.socketHandler,
    Key? key,
  }) : super(key: key);

  final IWebSocketHandler<ISocketMessage<dynamic>, IMessageToServer> socketHandler;

  @override
  State<WebsocketBaseScreen> createState() => _WebsocketBaseScreenState();
} // WebsocketBaseMockedScreen

/// State for widget WebsocketBaseMockedScreen
class _WebsocketBaseScreenState extends State<WebsocketBaseScreen> {
  IWebSocketHandler<ISocketMessage<dynamic>, IMessageToServer> get socketHandler => widget.socketHandler;
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Первичная инициализация виджета
  }

  @override
  void didUpdateWidget(WebsocketBaseScreen oldWidget) {
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
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SocketBaseDataListener(socketHandler: socketHandler),
          SocketBasicControls(socketHandler: socketHandler),
          SocketCurrentStatus(socketHandler: socketHandler),
        ],
      );
} // _WebsocketBaseMockedScreenState
