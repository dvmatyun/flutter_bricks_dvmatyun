import '../enums/socket_status_type.dart';

class SocketStatus {
  /// 0 - not connected
  /// 1 - connecting
  /// 2 - connected
  SocketStatusType statusType;
  String status;

  SocketStatus({required this.statusType, this.status = ''});
}
