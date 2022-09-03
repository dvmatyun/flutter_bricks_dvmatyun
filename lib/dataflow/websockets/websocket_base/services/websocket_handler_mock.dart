import 'dart:async';

import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/enums/socket_status_type.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/message_processor.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/models/socket_state_impl.dart';

import '../enums/socket_log_event_type.dart';
import '../interfaces/socket_log_event.dart';
import '../interfaces/socket_state.dart';
import '../interfaces/websocket_handler.dart';
import '../models/socket_log_event_impl.dart';

IWebSocketHandler<T, Y> createMockedWebsocketClient<T, Y>(
  String connectUrlBase,
  IMessageProcessor<T, Y> messageProcessor,
) =>
    WebsocketHandlerMock<T, Y>(
      connectUrlBase: connectUrlBase,
      messageProcessor: messageProcessor,
    );

class WebsocketHandlerMock<T, Y> implements IWebSocketHandler<T, Y> {
  /// consts:
  static const int _pingIntervalMs = 10000;
  static const int _baseDelayMs = 50;
  static const String _connectedPhrase = 'connected!';
  String _connectingPhrase(String url) => 'Connecting to [$url]...';

  final String _connectUrlBase;

  /// Serializer:
  final IMessageProcessor<T, Y> _messageProcessor;

  /// Messages TO server
  final _outgoingMessagesController = StreamController<String>.broadcast();
  @override
  Stream<String> get outgoingMessagesStream => _outgoingMessagesController.stream;
  StreamSubscription? _toServerMessagesSub;

  /// Messages FROM server:
  final _incomingMessagesController = StreamController<T>.broadcast();
  @override
  Stream<T> get incomingMessagesStream => _incomingMessagesController.stream;
  StreamSubscription? _fromServerMessagesSub;

  /// Socket state notifications:
  /// 0 - not connected
  /// 1 - connecting
  /// 2 - connected
  final StreamController<ISocketState> _socketStateController = StreamController<ISocketState>.broadcast();
  @override
  Stream<ISocketState> get socketStateStream => _socketStateController.stream;

  ISocketState _socketState = SocketStateImpl(status: SocketStatus.disconnected, message: 'Created');
  @override
  ISocketState get socketState => _socketState;

  final _debugEventController = StreamController<ISocketLogEvent>.broadcast();
  @override
  Stream<ISocketLogEvent> get logEventStream => _debugEventController.stream;

  /// Mock internal:
  Stream<String> get _echoStreamInternal => _websocketInternalController.stream.asyncMap((event) async {
        await Future<void>.delayed(const Duration(milliseconds: _baseDelayMs));
        return event;
      });
  final StreamController<String> _websocketInternalController = StreamController<String>.broadcast();

  /// Internal state parameters:
  bool _isConnected = false;
  bool _disposed = false;

  WebsocketHandlerMock({
    required String connectUrlBase,
    required IMessageProcessor<T, Y> messageProcessor,
  })  : _connectUrlBase = connectUrlBase,
        _messageProcessor = messageProcessor {
    _pingSocketState();
  }

  ///
  /// NOT CONNECTED
  /// Connecting:
  /// NOT CONNECTED
  ///
  @override
  Future<bool> connect() async {
    if (_disposed) {
      throw Exception('Socket is already disposed!');
    }
    try {
      final isConnected = await _connectionInitialize(_connectUrlBase);
      if (isConnected) {
        await _connectionSuccessful();
        return true;
      }
      await _connectionUnsuccessful();

      return false;
    } on Object catch (e) {
      _notifySocketStatusInternal(SocketStatus.error, e.toString());
      return false;
    }
  }

  Future<bool> _connectionInitialize(String baseUrl) async {
    if (_isConnected) {
      return false;
    }
    _notifySocketStatusInternal(SocketStatus.connecting, _connectingPhrase(baseUrl));
    await Future<void>.delayed(const Duration(milliseconds: _baseDelayMs)); // simulating connection time
    /*
      if (_webSocket?.closeCode != null) {
        _socketStateController.add(SocketState(statusType: SocketStatusType.disconnected, status: 'failed to connect!'));
        return false;
      }
    */
    return true;
  }

  Future<void> _connectionSuccessful() async {
    _isConnected = true;
    _notifySocketStatusInternal(SocketStatus.connected, _connectedPhrase);
    _initSubscriptions();
  }

  Future<void> _connectionUnsuccessful() async {}

  Future<void> _initSubscriptions() async {
    if (!_isConnected) {
      return disconnect('Connection with server was not established!');
    }
    await _listenMessagerFromServer();
    await _listenMessagesToServer();
  }

  ///
  /// CONNECTED
  /// Listeners TO and FROM server:
  /// CONNECTED
  ///
  Future<void> _listenMessagerFromServer() async {
    await _fromServerMessagesSub?.cancel();
    _fromServerMessagesSub = _echoStreamInternal.listen(_fromServerMessageInternal);
  }

  Future<void> _listenMessagesToServer() async {
    await _toServerMessagesSub?.cancel();
    _toServerMessagesSub =
        outgoingMessagesStream.takeWhile((_) => _isConnected).listen(_addMessageToSocketOutgoingInternal);
  }

  ///
  /// CONNECTED
  /// Operating with connected socket:
  /// CONNECTED
  ///
  @override
  void sendMessage(Y messageToServer) {
    if (_disposed) {
      return;
    }
    if (!_isConnected) {
      _debugEventNotificationInternal(SocketLogEventType.warning, 'Trying to send message when not connected!');
      return;
    }
    final outJsonMsg = _messageProcessor.serializeMessage(messageToServer);

    /// This controller's stream is listened by [_listenMessagesToServer()]
    _outgoingMessagesController.add(outJsonMsg);
  }

  /// Sending to server platform implementation:
  void _addMessageToSocketOutgoingInternal(String input) {
    try {
      /// Platform implementation here
      _debugEventNotificationInternal(SocketLogEventType.toServerMessage, 'to server', data: input);
      _websocketInternalController.add(input);
    } on Object catch (e) {
      _debugEventNotificationInternal(
        SocketLogEventType.error,
        'Sending message to server failed! Error: $e',
        data: input.toString(),
      );
    }
  }

  /// Listening from server implementation:
  void _fromServerMessageInternal(dynamic input) {
    try {
      final data = input as Object?;
      final msgFromServer = _messageProcessor.deserializeMessage(data);
      if (msgFromServer == null) {
        _debugEventNotificationInternal(SocketLogEventType.warning, 'Got NULL message from server!');
        return;
      }
      _debugEventNotificationInternal(
        SocketLogEventType.fromServerMessage,
        'from server',
        data: msgFromServer.toString(),
      );
      _incomingMessagesController.add(msgFromServer);
    } on Object catch (e) {
      _debugEventNotificationInternal(
        SocketLogEventType.error,
        'Deserializing message from server failed! Error: $e',
        data: input.toString(),
      );
    }
  }

  ///
  ///
  /// Internal stuff:
  ///
  ///

  void _notifySocketStatusInternal(SocketStatus status, String message) {
    if (_socketStateController.isClosed) {
      return;
    }
    _socketState = SocketStateImpl(status: status, message: message);
    _socketStateController.add(_socketState);
    _debugEventNotificationInternal(SocketLogEventType.socketStateChanged, message);
  }

  void _debugEventNotificationInternal(
    SocketLogEventType type,
    String message, {
    String? data,
  }) {
    if (_debugEventController.isClosed) {
      return;
    }
    _debugEventController.add(SocketLogEventImpl(
      socketLogEventType: type,
      status: _socketState.status,
      message: message,
      data: data,
    ));
  }

  Future<void> _pingSocketState() async {
    while (!_disposed) {
      await Future<void>.delayed(const Duration(milliseconds: _pingIntervalMs));
      if (!_isConnected) {
        continue;
      }
      _isConnectionAlivePing();
    }
  }

  void _isConnectionAlivePing() {
    final msg = 'Ping socket. ${_isConnected ? "Connected." : "Disconnected."}';
    _debugEventNotificationInternal(SocketLogEventType.ping, msg);
  }

  ///
  /// Closing & disconnecting
  ///
  @override
  Future<void> disconnect(String reason) async {
    if (!_isConnected) {
      return;
    }
    _isConnected = false;
    _notifySocketStatusInternal(SocketStatus.disconnected, reason);
  }

  @override
  void close() {
    _fromServerMessagesSub?.cancel();
    _outgoingMessagesController.close();
    _incomingMessagesController.close();
    _socketStateController.close();
    _websocketInternalController.close();
    _debugEventController.close();
    if (_isConnected) {
      disconnect('Close called');
    }
    _disposed = true;
  }
}
