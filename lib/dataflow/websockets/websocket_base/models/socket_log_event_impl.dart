import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/enums/socket_log_event_type.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/socket_log_event.dart';
import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/models/socket_state_impl.dart';

import '../enums/socket_status_type.dart';

class SocketLogEventImpl extends SocketStateImpl implements ISocketLogEvent {
  @override
  final SocketLogEventType socketLogEventType;

  @override
  final String? data;

  @override
  final int pingMs;

  SocketLogEventImpl({
    required this.socketLogEventType,
    required SocketStatus status,
    required this.pingMs,
    String message = '',
    this.data,
  }) : super(
          status: status,
          message: message,
        );
}
