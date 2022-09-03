import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/enums/socket_status_type.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/message_processor.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/models/socket_state_impl.dart';

import '../enums/socket_log_event_type.dart';
import '../interfaces/socket_log_event.dart';
import '../interfaces/socket_state.dart';
import '../interfaces/websocket_handler.dart';
import '../models/socket_log_event_impl.dart';

IWebSocketHandler<T, Y> createWebsocketClient<T, Y>(
  String connectUrlBase,
  IMessageProcessor<T, Y> messageProcessor, {
  int timeoutConnectionMs = 5000,
  int pingIntervalMs = 1000,
}) =>
    WebsocketHandlerIo<T, Y>(
      connectUrlBase: connectUrlBase,
      messageProcessor: messageProcessor,
      timeoutConnectionMs: timeoutConnectionMs,
      pingIntervalMs: pingIntervalMs,
    );

class WebsocketHandlerIo<T, Y> implements IWebSocketHandler<T, Y> {
  /// consts:
  final int _pingIntervalMs;
  final int _timeoutConnectionMs;
  static const String _connectedPhrase = 'connected!';
  String _connectingPhrase(String url) => 'Connecting to [$url]...';

  final String _connectUrlBase;

  /// Ping measurement:
  final _pingStopwatch = Stopwatch();
  @override
  int get pingDelayMs => _pingDelayMs;
  int _pingDelayMs = 0;

  /// Serializer:
  final IMessageProcessor<T, Y> _messageProcessor;

  /// Messages TO server
  final _outgoingMessagesController = StreamController<Object>.broadcast();
  @override
  Stream<Object> get outgoingMessagesStream => _outgoingMessagesController.stream;
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

  /// Internal state parameters:
  bool _disposed = false;

  /// Platform specific:
  io.WebSocket? _webSocket;
  String get platformStaus =>
      'Platform status: close code= ${_webSocket?.closeCode}, close reason=${_webSocket?.closeReason}';

  WebsocketHandlerIo({
    required String connectUrlBase,
    required IMessageProcessor<T, Y> messageProcessor,
    int timeoutConnectionMs = 5000,
    int pingIntervalMs = 1000,
  })  : _connectUrlBase = connectUrlBase,
        _messageProcessor = messageProcessor,
        _timeoutConnectionMs = timeoutConnectionMs,
        _pingIntervalMs = pingIntervalMs {
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
      _startPingMeasurement();
      final isConnected = await _connectionInitialize(_connectUrlBase);
      _setInitPing();
      if (isConnected) {
        await _connectionSuccessful();
        return true;
      }
      await _connectionUnsuccessful();

      return false;
    } on TimeoutException catch (e) {
      disconnect('Connection to [$_connectUrlBase] failed by timeout $_timeoutConnectionMs ms!');
      return false;
    } on Object catch (e) {
      disconnect('Internal error: $e');
      return false;
    }
  }

  Future<bool> _connectionInitialize(String baseUrl) async {
    if ([SocketStatus.connected, SocketStatus.connecting].contains(socketState.status)) {
      return false;
    }
    _notifySocketStatusInternal(SocketStatus.connecting, _connectingPhrase(baseUrl));
    var connectUrl = _connectUrlBase;
    if (io.Platform.isAndroid) {
      connectUrl = connectUrl.replaceAll('127.0.0.1', '10.0.2.2');
    }
    _webSocket = await io.WebSocket.connect(connectUrl).timeout(Duration(milliseconds: _timeoutConnectionMs));
    _isConnectionAlivePing();
    /*
      if (_webSocket?.closeCode != null) {
        _socketStateController.add(SocketState(statusType: SocketStatusType.disconnected, status: 'failed to connect!'));
        return false;
      }
    */
    return true;
  }

  Future<void> _connectionSuccessful() async {
    _notifySocketStatusInternal(SocketStatus.connected, _connectedPhrase);
    if (socketState.status != SocketStatus.connected) {
      return disconnect('Connection with server was not established!');
    }
    await _listenMessagerFromServer();
    await _listenMessagesToServer();
  }

  Future<void> _connectionUnsuccessful() async {}

  ///
  /// CONNECTED
  /// Listeners TO and FROM server:
  /// CONNECTED
  ///
  Future<void> _listenMessagerFromServer() async {
    _checkPlatformIsConnected('_listenMessagerFromServer');
    await _fromServerMessagesSub?.cancel();
    _fromServerMessagesSub = _webSocket?.listen(_fromServerMessageInternal);
  }

  Future<void> _listenMessagesToServer() async {
    _checkPlatformIsConnected('_listenMessagesToServer');
    await _toServerMessagesSub?.cancel();
    _toServerMessagesSub = outgoingMessagesStream
        .takeWhile((_) => socketState.status == SocketStatus.connected)
        .listen(_addMessageToSocketOutgoingInternal);
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
    if (socketState.status != SocketStatus.connected) {
      _debugEventNotificationInternal(SocketLogEventType.warning, 'Trying to send message when not connected!');
      return;
    }
    final outJsonMsg = _messageProcessor.serializeMessage(messageToServer);

    /// This controller's stream is listened by [_listenMessagesToServer()]
    _outgoingMessagesController.add(outJsonMsg);
  }

  /// Sending to server platform implementation:
  void _addMessageToSocketOutgoingInternal(Object input, {bool isPing = false}) {
    try {
      if (!isPing) {
        _debugEventNotificationInternal(SocketLogEventType.toServerMessage, 'to server', data: input.toString());
      } else {
        _startPingRequest();
      }

      /// Platform implementation here:
      _webSocket?.add(input);
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
      final isPingMessage = _messageProcessor.isPongMessageReceived(msgFromServer);
      if (isPingMessage) {
        _pongReceived();
      } else {
        _debugEventNotificationInternal(
          SocketLogEventType.fromServerMessage,
          'from server',
          data: msgFromServer.toString(),
        );
      }

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
    if ([SocketLogEventType.ping, SocketLogEventType.socketStateChanged].contains(type)) {
      message += platformStaus;
    }

    _debugEventController.add(SocketLogEventImpl(
      socketLogEventType: type,
      status: _socketState.status,
      message: message,
      pingMs: pingDelayMs,
      data: data,
    ));
  }

  Future<void> _pingSocketState() async {
    while (!_disposed) {
      try {
        await Future<void>.delayed(Duration(milliseconds: _pingIntervalMs));
        if (socketState.status != SocketStatus.connected) {
          continue;
        }
        _isConnectionAlivePing();
      } on Object catch (e) {
        _debugEventNotificationInternal(
          SocketLogEventType.ping,
          'Error occured while pinging: $e',
        );
      }
    }
  }

  bool _checkPlatformIsConnected(String whoChecks) {
    if (_webSocket == null) {
      _debugEventNotificationInternal(
        SocketLogEventType.error,
        '$whoChecks : _webSocket object is NULL!',
      );
      return false;
    }
    if (_webSocket?.readyState != 1) {
      _debugEventNotificationInternal(
        SocketLogEventType.error,
        '$whoChecks : _webSocket readyState != 1 !!! $platformStaus',
      );
      return false;
    }
    if (_webSocket?.closeCode != null) {
      _debugEventNotificationInternal(
        SocketLogEventType.error,
        '$whoChecks : _webSocket closeCode is not NULL! $platformStaus',
      );
      return false;
    }
    return true;
  }

  void _isConnectionAlivePing({String? message}) {
    _addMessageToSocketOutgoingInternal(_messageProcessor.pingServerMessage, isPing: true);
    final msg = 'Ping socket. Status: ${socketState.status.value}.';
    _debugEventNotificationInternal(SocketLogEventType.ping, message == null ? msg : '$msg ($message)');
    if (!_checkPlatformIsConnected('Ping socket.')) {
      disconnect('Connection appeared to be closed during pinging websocket platform status!');
    }
  }

  ///
  /// Ping measurement:
  ///
  bool _isPongReceived = false;
  void _startPingRequest() {
    if (!_isPongReceived) {
      _recalculateCurrentPing(_pingStopwatch.elapsedMilliseconds);
    }
    _pingStopwatch.start();
    _isPongReceived = false;
  }

  void _pongReceived() {
    if (!_pingStopwatch.isRunning) {
      return;
    }
    _isPongReceived = true;
    _recalculateCurrentPing(_pingStopwatch.elapsedMilliseconds);
    _debugEventNotificationInternal(
      SocketLogEventType.pong,
      'pong from server (${_pingStopwatch.elapsedMilliseconds} ms.)',
    );
    _resetStopwatch();
  }

  void _resetStopwatch() {
    _pingStopwatch.stop();
    _pingStopwatch.reset();
  }

  void _recalculateCurrentPing(int newPingValue) {
    _pingDelayMs = (_pingDelayMs + newPingValue) ~/ 2;
  }

  void _startPingMeasurement() {
    _resetStopwatch();
    _pingStopwatch.start();
  }

  void _setInitPing() {
    if (!_pingStopwatch.isRunning) {
      return;
    }
    _pingDelayMs = _pingStopwatch.elapsedMilliseconds;
    _resetStopwatch();
    _isPongReceived = true;
  }

  ///
  /// Closing & disconnecting
  ///
  @override
  Future<void> disconnect(String reason) async {
    _pingStopwatch.stop();
    if (socketState.status == SocketStatus.disconnected) {
      return;
    }
    await _webSocket?.close(3001, 'Requested by user!');
    _notifySocketStatusInternal(SocketStatus.disconnected, reason);
  }

  @override
  void close() {
    _pingStopwatch.stop();
    _fromServerMessagesSub?.cancel();
    _outgoingMessagesController.close();
    _incomingMessagesController.close();
    _socketStateController.close();
    _debugEventController.close();
    if (socketState.status != SocketStatus.disconnected) {
      disconnect('Close called (disposal)');
    }
    _disposed = true;
  }
}
