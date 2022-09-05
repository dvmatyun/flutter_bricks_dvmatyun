import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../websocket_universal.dart';

/// SocketBytesControls
class SocketBytesControls extends StatelessWidget {
  const SocketBytesControls({
    required this.socketHandler,
    Key? key,
  }) : super(key: key);

  final IWebSocketHandler<List<int>, List<int>> socketHandler;

  IMessageToServer get rawMessage => MessageToServerImpl.duo(
        host: 'host',
        topic1: 'topic1',
        data: '{"payload": "some-payload"}',
      );

  List<int> get fakeMessage => utf8.encode(jsonEncode(rawMessage.toJson()));

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
} // SocketBytesControls
