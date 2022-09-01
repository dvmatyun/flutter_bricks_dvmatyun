import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/enums/socket_status_type.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/message_to_server.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/models/socket_message_impl.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/models/socket_status_impl.dart';

import '../interfaces/websocket_handler.dart';

WebSocketHandler createWebsocketClient(String connectUrlBase) => WebsocketHandlerIo(connectUrlBase: connectUrlBase);

class WebsocketHandlerIo implements WebSocketHandler {
  static const String _logName = '[WebSocket IO]';
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
  bool _disposed = false;
  final onCloseScInternal = StreamController<String>.broadcast();
  StreamSubscription? _subClose;
  StreamSubscription? _subInMessage;

  io.WebSocket? _webSocket;

  WebsocketHandlerIo({required String connectUrlBase}) : _connectUrlBase = connectUrlBase {
    incomingMessagesStream = _incomingMessagesController.stream;
    _pingSocketStatus();
  }

  @override
  void close() {
    _disposed = true;
    _subInMessage?.cancel();
    _subClose?.cancel();
    _outgoingMessagesController.close();
    _incomingMessagesController.close();
    _connectionStatusController.close();
    onCloseScInternal.close();
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
    onCloseScInternal.add(_webSocket?.closeReason ?? 'unknown');
    await _closeSubscriptions();
    if (_webSocket?.readyState == 1) {
      await _webSocket?.close(3001, 'Requested by user!');
    }
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController
          .add(SocketStatus(statusType: SocketStatusType.disconnected, status: 'Manual disconnect!'));
    }
  }

  @override
  void sendMessage(IMessageToServer messageToServer) {
    if (_disposed) {
      return;
    }
    if (!_isConnected) {
      return;
    }
    final outJsonMsg = jsonEncode(messageToServer.toJson());
    _outgoingMessagesController.add(outJsonMsg);
  }

  Future<void> _pingSocketStatus() async {
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
      _connectionStatusController.add(SocketStatus(statusType: SocketStatusType.connecting, status: 'connecting...'));

      var connectUrl = _connectUrlBase;
      if (io.Platform.isAndroid) {
        connectUrl = connectUrl.replaceAll('127.0.0.1', '10.0.2.2');
      }
      _webSocket = await io.WebSocket.connect(connectUrl).timeout(const Duration(seconds: 5));

      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (_webSocket?.readyState != 1) {
        await _webSocket?.close();
        _connectionStatusController
            .add(SocketStatus(statusType: SocketStatusType.disconnected, status: 'failed to connect!'));
        return false;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await _initSubscriptions();
      _webSocket?.pingInterval = const Duration(seconds: 1);

      if (_webSocket?.closeCode != null) {
        _connectionStatusController
            .add(SocketStatus(statusType: SocketStatusType.disconnected, status: 'Connection failed!'));
        return false;
      }

      _isConnected = true;
      _outgoingMessagesController.add(_connectedPhrase);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      return true;
    } on Object catch (e) {
      _connectionStatusController.add(SocketStatus(statusType: SocketStatusType.disconnected, status: e.toString()));
      return false;
    }
  }

  Future<void> _initSubscriptions() async {
    await _closeSubscriptions();
    _subClose = onCloseScInternal.stream.listen((event) {
      _connectionStatusController.add(SocketStatus(statusType: SocketStatusType.disconnected, status: event));
    });
    _subInMessage = _webSocket?.listen((dynamic event) {
      final data = event as Object?;
      if (data is! String) {
        return;
      }
      final wsMessage = SocketMessageImpl.fromJson(jsonDecode(data) as Map<String, Object?>);
      _incomingMessagesController.add(wsMessage);
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
            _connectionStatusController
                .add(SocketStatus(statusType: SocketStatusType.connected, status: _connectedPhrase));
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
