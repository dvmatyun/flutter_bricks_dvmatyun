import 'package:flutter/material.dart';
import '../../../../websocket_universal.dart';
import 'widgets/socket_bytes_controls.dart';
import 'widgets/socket_bytes_current_status.dart';
import 'widgets/socket_bytes_data_listener.dart';

/// WebsocketBaseMockedScreen
class WebsocketBytesScreen extends StatefulWidget {
  const WebsocketBytesScreen({
    required this.socketHandler,
    Key? key,
  }) : super(key: key);

  final IWebSocketHandler<List<int>, List<int>> socketHandler;

  @override
  State<WebsocketBytesScreen> createState() => _WebsocketBytesScreenState();
} // WebsocketBaseMockedScreen

/// State for widget WebsocketBaseMockedScreen
class _WebsocketBytesScreenState extends State<WebsocketBytesScreen> {
  IWebSocketHandler<List<int>, List<int>> get socketHandler => widget.socketHandler;
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Первичная инициализация виджета
  }

  @override
  void didUpdateWidget(WebsocketBytesScreen oldWidget) {
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
          SocketBytesDataListener(socketHandler: socketHandler),
          SocketBytesControls(socketHandler: socketHandler),
          SocketBytesCurrentStatus(socketHandler: socketHandler),
        ],
      );
} // _WebsocketBaseMockedScreenState
