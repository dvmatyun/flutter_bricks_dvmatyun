import 'package:flutter/material.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_message.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_params.dart';

typedef TypedMessageBuilder = Widget Function(OverlayMessage typedMessage);

abstract class ITopMessageNotificator {
  void showSlidingOverlayFromTop({required Widget child, required OverlayParams overlayParams});

  void hideSlidingOverlay({String? key});
  void immediateHideOverlay({String? key});
  bool isOverlayIsShown(String key);

  void close();
}
