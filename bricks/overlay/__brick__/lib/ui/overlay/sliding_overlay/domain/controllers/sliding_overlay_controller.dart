import 'package:flutter/material.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_params.dart';

///https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html

typedef OverlayInsertFunc = void Function(OverlayEntry overlayEntry);

abstract class ISlidingOverlayController {
  void showSlidingOverlayFromTop({required Widget child, required OverlayParams overlayParams});

  void hideSlidingOverlay({String? key});
  void immediateHideOverlay({String? key});

  /// Map that shows whether entry is on the screen right now (value is true - on the screen)
  Map<String, bool> get entriesStates;
  bool isOverlayIsShown(String key);

  void close();
}
