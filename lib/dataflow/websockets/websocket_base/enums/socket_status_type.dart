enum SocketStatus {
  disconnected('disconnected'),
  connecting('connecting'),
  connected('connected'),
  error('error');

  final String value;
  const SocketStatus(this.value);
}
