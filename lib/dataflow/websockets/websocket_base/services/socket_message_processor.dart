import 'dart:convert';

import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/models/socket_message_impl.dart';

import '../interfaces/message_processor.dart';
import '../interfaces/message_to_server.dart';
import '../interfaces/socket_message.dart';

class SocketMessageProcessor implements IMessageProcessor<ISocketMessage<dynamic>, IMessageToServer> {
  @override
  ISocketMessage? deserializeMessage(Object? data) {
    if (data is! String) {
      return null;
    }
    final wsMessage = SocketMessageImpl.fromJson(jsonDecode(data) as Map<String, Object?>);
    return wsMessage;
  }

  @override
  String serializeMessage(IMessageToServer message) => jsonEncode(message.toJson());
}