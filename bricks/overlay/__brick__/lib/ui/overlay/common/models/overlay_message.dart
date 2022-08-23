import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_params.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/typed_message.dart';

class OverlayMessage {
  final String type;
  final String message;

  final OverlayParams overlayParams;

  OverlayMessage({
    required TypedMessage typedMessage,
    required this.overlayParams,
  })  : type = typedMessage.type,
        message = typedMessage.message;
}
