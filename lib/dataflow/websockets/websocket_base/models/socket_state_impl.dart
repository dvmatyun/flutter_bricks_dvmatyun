import 'package:flutter_bricks_dvmatyun/dataflow/websockets/websocket_base/interfaces/socket_state.dart';

import '../enums/socket_status_type.dart';

class SocketStateImpl implements ISocketState {
  @override
  final SocketStatus status;
  @override
  final String message;

  @override
  final DateTime time;

  SocketStateImpl({required this.status, this.message = ''}) : time = DateTime.now();
}
