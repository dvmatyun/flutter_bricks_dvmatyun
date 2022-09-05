import 'package:flutter/material.dart';
import '../../../../websocket_universal.dart';

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
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text('status: ${data?.status.value}'),
                Text('status message: ${data?.message}'),
              ],
            ),
          );
        },
      );
} // SocketCurrentStatus
