enum SocketLogEventType {
  error('error'),
  warning('warning'),
  ping('ping'),
  socketStateChanged('socketStateChanged'),
  toServerMessage('toServerMessage'),
  fromServerMessage('fromServerMessage');

  final String value;
  const SocketLogEventType(this.value);
}
