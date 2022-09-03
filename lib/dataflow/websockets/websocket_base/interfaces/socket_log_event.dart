import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/socket_state.dart';

import '../enums/socket_log_event_type.dart';

abstract class ISocketLogEvent implements ISocketState {
  SocketLogEventType get socketLogEventType;
  String? get data;
  int get pingMs;
}
