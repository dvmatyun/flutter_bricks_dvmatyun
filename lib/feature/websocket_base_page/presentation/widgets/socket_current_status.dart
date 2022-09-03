import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/message_to_server.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/socket_message.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/socket_state.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/websocket_handler.dart';

/// SocketCurrentStatus
class SocketCurrentStatus extends StatelessWidget {
  const SocketCurrentStatus({
    required this.socketHandler,
    Key? key,
  }) : super(key: key);

  final IWebSocketHandler<ISocketMessage<dynamic>, IMessageToServer> socketHandler;

  @override
  Widget build(BuildContext context) => StreamBuilder<ISocketState>(
        initialData: socketHandler.socketState,
        stream: socketHandler.socketStateStream,
        builder: (context, state) {
          if (!state.hasData) {
            return const Center(
              child: Text('No data...'),
            );
          }
          final data = state.data;
          return Column(
            children: [
              Text('status: ${data?.status.value}'),
              Text('status message: ${data?.message}'),
            ],
          );
        },
      );
} // SocketCurrentStatus
