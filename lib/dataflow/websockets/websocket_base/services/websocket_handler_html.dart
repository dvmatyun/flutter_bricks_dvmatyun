import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/models/socket_state_impl.dart';

import '../enums/socket_status_type.dart';
import '../interfaces/message_processor.dart';
import '../interfaces/socket_log_event.dart';
import '../interfaces/socket_state.dart';
import '../interfaces/websocket_handler.dart';

IWebSocketHandler<T, Y> createWebsocketClient<T, Y>(
  String connectUrlBase,
  IMessageProcessor<T, Y> messageProcessor, {
  int timeoutConnectionMs = 5000,
  int pingIntervalMs = 1000,
}) =>
    WebsocketHandlerHtml<T, Y>(connectUrlBase: connectUrlBase, messageProcessor: messageProcessor);

class WebsocketHandlerHtml<T, Y> implements IWebSocketHandler<T, Y> {
  final String _connectUrlBase;

  final _outgoingMessagesController = StreamController<Object>.broadcast();
  @override
  Stream<Object> get outgoingMessagesStream => _outgoingMessagesController.stream;

  @override
  int get pingDelayMs => 100;

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
  bool _isDisposed = false;
  StreamSubscription? _subClose;
  StreamSubscription? _subOpen;
  StreamSubscription? _subError;
  StreamSubscription? _subInMessage;

  html.WebSocket? _webSocket;
  final IMessageProcessor<T, Y> _messageProcessor;

  WebsocketHandlerHtml({
    required String connectUrlBase,
    required IMessageProcessor<T, Y> messageProcessor,
  })  : _connectUrlBase = connectUrlBase,
        _messageProcessor = messageProcessor;

  @override
  void close() {
    disconnect('[called close()]');
    _subInMessage?.cancel();
    _subClose?.cancel();
    _subOpen?.cancel();
    _subError?.cancel();
    _outgoingMessagesController.close();
    _incomingMessagesController.close();
    _socketStateController.close();
    _debugEventController.close();
    _isDisposed = true;
  }

  static const String traceName = '[WebSocket HTML] ';
  static const int timeoutMs = 5000;
  static const int pingEvery = 250;

  @override
  Future<void> disconnect(String reason) async {
    //l.v('$traceName disconnect start. Reason: $reason');
    _isConnected = false;
    await _closeSubscriptions();
    if (_webSocket?.readyState == 1) {
      _webSocket?.close(3001, 'Requested by user!');
    }
    if (!_socketStateController.isClosed) {
      _socketStateController.add(SocketStateImpl(status: SocketStatus.disconnected, message: 'Manual disconnect!'));
    }
    //l.v('$traceName disconnect end!');
  }

  @override
  void sendMessage(Y messageToServer) {
    if (_isDisposed) {
      throw Exception('Socket is already disposed!');
    }
    if (!_isConnected) {
      return;
    }
    final outJsonMsg = _messageProcessor.serializeMessage(messageToServer);
    _outgoingMessagesController.add(outJsonMsg);
  }

  @override
  Future<bool> connect() async {
    if (_isDisposed) {
      throw Exception('Socket is already disposed!');
    }
    try {
      _socketStateController.add(SocketStateImpl(status: SocketStatus.connecting, message: 'connecting...'));
      //final storedUser = AppUser(userName: username, loginStoredToken: loginToken);
      final connectUrl = _connectUrlBase;
      _webSocket = html.WebSocket(connectUrl);
      //l.v('$traceName try connect to [$connectUrl]');

      await _initSubscriptions();
      for (var i = 0; i < (timeoutMs ~/ pingEvery); i++) {
        await Future<void>.delayed(const Duration(milliseconds: pingEvery));
        if (_isConnected) {
          _socketStateController.add(SocketStateImpl(status: SocketStatus.connected, message: 'connected!'));
          return true;
        }
      }
      _webSocket?.close(3001, 'Requested by user.');
      _socketStateController.add(SocketStateImpl(status: SocketStatus.disconnected, message: 'failed to connect!'));
      return false;
    } on Object catch (e) {
      _socketStateController.add(SocketStateImpl(status: SocketStatus.disconnected, message: e.toString()));
      return false;
    }
  }

  Future<void> _initSubscriptions() async {
    await _closeSubscriptions();
    _subOpen = _webSocket?.onOpen.listen((event) async {
      if (!_isConnected) {
        //l.v('$traceName connected: ${event.type}');
        final _ = _socketHandler();
      }
      _isConnected = true;
    });
    _subClose = _webSocket?.onClose.listen((event) async {
      await disconnect('[onClose() subscription]');
    });
    _subError = _webSocket?.onError.listen((event) {
      //l.v('$traceName onError: ${event.type}, ${event.toString()}');
    });

    _subInMessage = _webSocket!.onMessage.listen((dynamic event) {
      final data = event.data as Object?;
      final msgFromServer = _messageProcessor.deserializeMessage(data);
      if (msgFromServer == null) {
        return;
      }
      //l.v('$traceName as [at minute : ${DateTime.now().minute}:${DateTime.now().second}] ${data.toString()}'.substring(0, 50));
      _incomingMessagesController.add(msgFromServer);
    });
  }

  Future<void> _closeSubscriptions() async {
    await _subClose?.cancel();
    await _subInMessage?.cancel();
    await _subOpen?.cancel();
    await _subError?.cancel();
    if (!_outgoingMessagesController.isClosed) {
      _outgoingMessagesController.add('check');
    }
  }

  static const String _cancelHandler = '/q';
  Future<void> _socketHandler() async {
    if (_webSocket?.readyState != 1) {
      //l.v('Подключение не установлено!');
      throw UnsupportedError('Подключение с сервером не было установлено.');
    }

    //l.v("Подключение установлено.\nВведите сообщение или '$_cancelHandler' для выхода.");
    /*
    await outgoingMessagesStream
        .takeWhile((String input) {
          if (input.trim().toLowerCase() == _cancelHandler || !_isConnected) {
            return false;
          }
          //l.v('> websocket io sendMessage: [$input]');
          _webSocket?.send(input);
          return true;
        })
        .drain<void>()
        .whenComplete(() => disconnect('[_socketHandler ended]'));
        */
    //l.v('Подключение закончено.');
  }

// Попрощаемся
  Future<void> onDone() async {
    //l.v('Конец');
  }

// Выведем непредвиденную ошибку
  Future<void> onError(Object error) async {
    //l.v('НЕ ПРЕДВИДЕННАЯ ОШИБКА: ${error}');
  }
}
