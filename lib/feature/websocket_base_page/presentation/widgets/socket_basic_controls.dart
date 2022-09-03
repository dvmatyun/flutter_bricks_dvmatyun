import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/message_to_server.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/socket_message.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/websocket_handler.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/models/message_to_server_impl.dart';

/// SocketBasicControls
class SocketBasicControls extends StatelessWidget {
  const SocketBasicControls({
    required this.socketHandler,
    Key? key,
  }) : super(key: key);

  final IWebSocketHandler<ISocketMessage<dynamic>, IMessageToServer> socketHandler;

  IMessageToServer get fakeMessage => MessageToServerImpl.duo(
        host: 'host',
        topic1: 'topic1',
        data: '{"payload": "some-payload"}',
      );

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => socketHandler.connect(),
            child: const Text('connect'),
          ),
          TextButton(
            onPressed: () => socketHandler.disconnect('Manual disconnect.'),
            child: const Text('disconnect'),
          ),
          TextButton(
            onPressed: () => socketHandler.sendMessage(fakeMessage),
            child: const Text('send message'),
          ),
        ],
      );
} // SocketBasicControls
