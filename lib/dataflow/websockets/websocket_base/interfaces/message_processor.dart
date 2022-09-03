abstract class IMessageProcessor<T, Y> {
  T? deserializeMessage(Object? data);
  String serializeMessage(Y message);
}
