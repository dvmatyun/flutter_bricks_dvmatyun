import 'package:flutter/material.dart';
import '../../../../websocket_universal.dart';

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
