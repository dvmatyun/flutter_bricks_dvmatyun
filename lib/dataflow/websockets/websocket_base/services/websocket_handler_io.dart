import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/enums/socket_status_type.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/models/socket_state_impl.dart';

import '../interfaces/message_processor.dart';
import '../interfaces/socket_log_event.dart';
import '../interfaces/socket_state.dart';
import '../interfaces/websocket_handler.dart';

IWebSocketHandler<T, Y> createWebsocketClient<T, Y>(String connectUrlBase, IMessageProcessor<T, Y> messageProcessor) =>
    WebsocketHandlerIo<T, Y>(connectUrlBase: connectUrlBase, messageProcessor: messageProcessor);

class WebsocketHandlerIo<T, Y> implements IWebSocketHandler<T, Y> {
  final String _connectUrlBase;

  final StreamController<String> _outgoingMessagesController = StreamController<String>.broadcast();
  @override
  Stream<String> get outgoingMessagesStream => _outgoingMessagesController.stream;

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

  final StreamController<T> _incomingMessagesController = StreamController<T>.broadcast();
  @override
  Stream<T> get incomingMessagesStream => _incomingMessagesController.stream;

  bool _isConnected = false;
  bool _disposed = false;
  final _onCloseScInternal = StreamController<String>.broadcast();
  StreamSubscription? _subClose;
  StreamSubscription? _subInMessage;

  io.WebSocket? _webSocket;

  final IMessageProcessor<T, Y> _messageProcessor;

  WebsocketHandlerIo({
    required String connectUrlBase,
    required IMessageProcessor<T, Y> messageProcessor,
  })  : _connectUrlBase = connectUrlBase,
        _messageProcessor = messageProcessor {
    _pingSocketState();
  }

  @override
  void close() {
    _disposed = true;
    _subInMessage?.cancel();
    _subClose?.cancel();
    _outgoingMessagesController.close();
    _incomingMessagesController.close();
    _socketStateController.close();
    _onCloseScInternal.close();
    _debugEventController.close();
    if (_webSocket?.readyState == 1) {
      _webSocket?.close(3001, 'Requested by user!');
    }
  }

  @override
  Future<void> disconnect(String reason) async {
    if (_disposed) {
      return;
    }
    //l.v('$_logName disconnect!!!  Reason: $reason');
    _isConnected = false;
    _onCloseScInternal.add(_webSocket?.closeReason ?? 'unknown');
    await _closeSubscriptions();
    if (_webSocket?.readyState == 1) {
      await _webSocket?.close(3001, 'Requested by user!');
    }
    if (!_socketStateController.isClosed) {
      _socketStateController.add(SocketStateImpl(status: SocketStatus.disconnected, message: 'Manual disconnect!'));
    }
  }

  @override
  void sendMessage(Y messageToServer) {
    if (_disposed) {
      return;
    }
    if (!_isConnected) {
      return;
    }
    final outJsonMsg = _messageProcessor.serializeMessage(messageToServer);
    _outgoingMessagesController.add(outJsonMsg);
  }

  Future<void> _pingSocketState() async {
    while (!_disposed) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!_isConnected) {
        continue;
      }

      if (_webSocket?.closeCode != null && !_disposed) {
        await disconnect('[_pingSocketStatus close code: ${_webSocket?.closeCode}, _isDisposed: $_disposed]');
      } else {
        //l.v('$_logName connected...');
      }
    }
  }

  @override
  Future<bool> connect() async {
    if (_disposed) {
      throw Exception('Socket is already disposed!');
    }
    try {
      _socketStateController.add(SocketStateImpl(status: SocketStatus.connecting, message: 'connecting...'));

      var connectUrl = _connectUrlBase;
      if (io.Platform.isAndroid) {
        connectUrl = connectUrl.replaceAll('127.0.0.1', '10.0.2.2');
      }
      _webSocket = await io.WebSocket.connect(connectUrl).timeout(const Duration(seconds: 5));

      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (_webSocket?.readyState != 1) {
        await _webSocket?.close();
        _socketStateController.add(SocketStateImpl(status: SocketStatus.disconnected, message: 'failed to connect!'));
        return false;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await _initSubscriptions();
      _webSocket?.pingInterval = const Duration(seconds: 1);

      if (_webSocket?.closeCode != null) {
        _socketStateController.add(SocketStateImpl(status: SocketStatus.disconnected, message: 'Connection failed!'));
        return false;
      }

      _isConnected = true;
      _outgoingMessagesController.add(_connectedPhrase);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      return true;
    } on Object catch (e) {
      _socketStateController.add(SocketStateImpl(status: SocketStatus.disconnected, message: e.toString()));
      return false;
    }
  }

  Future<void> _initSubscriptions() async {
    await _closeSubscriptions();
    _subClose = _onCloseScInternal.stream.listen((event) {
      _socketStateController.add(SocketStateImpl(status: SocketStatus.disconnected, message: event));
    });
    _subInMessage = _webSocket?.listen((dynamic event) {
      final data = event as Object?;
      final msgFromServer = _messageProcessor.deserializeMessage(data);
      if (msgFromServer == null) {
        return;
      }
      _incomingMessagesController.add(msgFromServer);
    });
    _webSocket?.pingInterval = const Duration(seconds: 1);
    // ignore: unawaited_futures
    _socketHandler();
  }

  Future<void> _closeSubscriptions() async {
    await _subClose?.cancel();
    await _subInMessage?.cancel();
    if (!_outgoingMessagesController.isClosed) {
      _outgoingMessagesController.add('check');
    }
  }

  static const String _connectedPhrase = 'connected!';
  static const String _cancelHandler = '/q';
  Future<void> _socketHandler() async {
    if (_webSocket?.readyState != 1) {
      throw UnsupportedError('Подключение с сервером не было установлено.');
    }

    await outgoingMessagesStream
        .takeWhile((String input) {
          if (input.trim().toLowerCase() == _cancelHandler || !_isConnected) {
            return false;
          }
          if (input == _connectedPhrase) {
            _disposed = false;
            _socketStateController.add(SocketStateImpl(status: SocketStatus.connected, message: _connectedPhrase));
          }
          _webSocket?.add(input);
          return true;
        })
        .drain<void>()
        .whenComplete(() => disconnect('[_socketHandler ended]'));
  }

// Попрощаемся
  Future<void> onDone() async {}

// Выведем непредвиденную ошибку
  Future<void> onError(Object error) async {}
}
