import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_params.dart';

class TypedMessage {
  final String type;
  final String message;

  final OverlayParams overlayParams;

  const TypedMessage({
    required this.type,
    required this.message,
    required this.overlayParams,
  });
}
