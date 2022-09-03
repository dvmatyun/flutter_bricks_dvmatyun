import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/message_to_server.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/socket_message.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/websocket_handler.dart';
import 'package:flutter_bricks_dvmatyun/feature/websocket_base_page/presentation/widgets/socket_current_status.dart';

import 'widgets/socket_base_data_listener.dart';
import 'widgets/socket_basic_controls.dart';

/// WebsocketBaseMockedScreen
class WebsocketBaseMockedScreen extends StatefulWidget {
  const WebsocketBaseMockedScreen({
    required this.socketHandler,
    Key? key,
  }) : super(key: key);

  final IWebSocketHandler<ISocketMessage<dynamic>, IMessageToServer> socketHandler;

  @override
  State<WebsocketBaseMockedScreen> createState() => _WebsocketBaseMockedScreenState();
} // WebsocketBaseMockedScreen

/// State for widget WebsocketBaseMockedScreen
class _WebsocketBaseMockedScreenState extends State<WebsocketBaseMockedScreen> {
  IWebSocketHandler<ISocketMessage<dynamic>, IMessageToServer> get socketHandler => widget.socketHandler;
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Первичная инициализация виджета
  }

  @override
  void didUpdateWidget(WebsocketBaseMockedScreen oldWidget) {
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
