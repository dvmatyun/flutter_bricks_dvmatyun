/// Websocket processor interface
/// for [Tin]-typed input messages from server
/// and [Yout]-typed outgoing messages to server
abstract class IMessageProcessor<Tin, Yout> {
  /// Deserialize message received from server
  /// Called after [isPongMessageReceived].
  /// Skipped if [isPongMessageReceived] return true for performance purpose.
  Tin? deserializeMessage(Object? data);

  /// Serialize message to server
  /// For multiplatform it can be [String]
  /// For IO ws data also can be a `List<int>` holding bytes
  Object serializeMessage(Yout message);

  /// Ping message that is sent to server.
  /// At this point it should be either [String] or [Yout] type
  /// For IO ws data also can be a `List<int>` holding bytes
  Object get pingServerMessage;

  /// Receiving pong message from server.
  /// Recommended to be a fast and cheap function.
  bool isPongMessageReceived(Object? data);
}
