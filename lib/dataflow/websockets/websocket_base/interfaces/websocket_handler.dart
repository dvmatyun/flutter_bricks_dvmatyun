import 'dart:async';

import '../models/socket_status_impl.dart';
import '../services/websocket_handler_io.dart'

// ignore: uri_does_not_exist
    if (dart.library.html) '../services/websocket_handler_html.dart';
import 'message_to_server.dart';
import 'socket_message.dart';

abstract class WebSocketHandler {
  Stream<String> get outgoingMessagesStream;
  Stream<ISocketMessage<dynamic>> get incomingMessagesStream;

  /// 0 - not connected
  /// 1 - connecting
  /// 2 - connected
  Stream<SocketStatus> get connectionStatusStream;

  Future<bool> connect();
  Future<void> disconnect(String reason);

  void sendMessage(IMessageToServer messageToServer);

  void close();

  factory WebSocketHandler.createClient(String connectUrlBase) => createWebsocketClient(connectUrlBase);
}
