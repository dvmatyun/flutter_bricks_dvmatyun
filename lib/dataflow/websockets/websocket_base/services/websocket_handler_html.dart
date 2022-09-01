import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../enums/socket_status_type.dart';
import '../interfaces/message_to_server.dart';
import '../interfaces/websocket_handler.dart';
import '../models/socket_message_impl.dart';
import '../models/socket_status_impl.dart';

WebSocketHandler createWebsocketClient(String connectUrlBase) => WebsocketHandlerHtml(connectUrlBase: connectUrlBase);

class WebsocketHandlerHtml implements WebSocketHandler {
  final String _connectUrlBase;

  final StreamController<String> _outgoingMessagesController = StreamController<String>.broadcast();
  @override
  late final Stream<String> outgoingMessagesStream = _outgoingMessagesController.stream;

  /// 0 - not connected
  /// 1 - connecting
  /// 2 - connected
  final StreamController<SocketStatus> _connectionStatusController = StreamController<SocketStatus>.broadcast();
  @override
  late final Stream<SocketStatus> connectionStatusStream = _connectionStatusController.stream;

  final StreamController<SocketMessageImpl> _incomingMessagesController =
      StreamController<SocketMessageImpl>.broadcast();

  @override
  late final Stream<SocketMessageImpl> incomingMessagesStream;

  bool _isConnected = false;
  bool _isDisposed = false;
  StreamSubscription? _subClose;
  StreamSubscription? _subOpen;
  StreamSubscription? _subError;
  StreamSubscription? _subInMessage;

  html.WebSocket? _webSocket;

  WebsocketHandlerHtml({required String connectUrlBase}) : _connectUrlBase = connectUrlBase {
    incomingMessagesStream = _incomingMessagesController.stream;
  }

  @override
  void close() {
    _isDisposed = true;
    disconnect('[called close()]');
    _subInMessage?.cancel();
    _subClose?.cancel();
    _subOpen?.cancel();
    _subError?.cancel();
    _outgoingMessagesController.close();
    _incomingMessagesController.close();
    _connectionStatusController.close();
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
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController
          .add(SocketStatus(statusType: SocketStatusType.disconnected, status: 'Manual disconnect!'));
    }
    //l.v('$traceName disconnect end!');
  }

  @override
  void sendMessage(IMessageToServer messageToServer) {
    if (_isDisposed) {
      throw Exception('Socket is already disposed!');
    }
    if (!_isConnected) {
      return;
    }
    final outJsonMsg = jsonEncode(messageToServer.toJson());
    _outgoingMessagesController.add(outJsonMsg);
  }

  @override
  Future<bool> connect() async {
    if (_isDisposed) {
      throw Exception('Socket is already disposed!');
    }
    try {
      _connectionStatusController.add(SocketStatus(statusType: SocketStatusType.connecting, status: 'connecting...'));
      //final storedUser = AppUser(userName: username, loginStoredToken: loginToken);
      final connectUrl = _connectUrlBase;
      _webSocket = html.WebSocket(connectUrl);
      //l.v('$traceName try connect to [$connectUrl]');

      await _initSubscriptions();
      for (var i = 0; i < (timeoutMs ~/ pingEvery); i++) {
        await Future<void>.delayed(const Duration(milliseconds: pingEvery));
        if (_isConnected) {
          _connectionStatusController.add(SocketStatus(statusType: SocketStatusType.connected, status: 'connected!'));
          return true;
        }
      }
      _webSocket?.close(3001, 'Requested by user.');
      _connectionStatusController
          .add(SocketStatus(statusType: SocketStatusType.disconnected, status: 'failed to connect!'));
      return false;
    } on Object catch (e) {
      _connectionStatusController.add(SocketStatus(statusType: SocketStatusType.disconnected, status: e.toString()));
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
      if (data is! String) {
        return;
      }
      //l.v('$traceName as [at minute : ${DateTime.now().minute}:${DateTime.now().second}] ${data.toString()}'.substring(0, 50));

      _incomingMessagesController.add(SocketMessageImpl.fromJson(jsonDecode(data) as Map<String, Object?>));
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
