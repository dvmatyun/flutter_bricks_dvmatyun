import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/common/models/overlay_params.dart';

///https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html

typedef OverlayInsertFunc = void Function(OverlayEntry overlayEntry);

abstract class ISlidingOverlayController {
  void showSlidingOverlayFromTop({required Widget child, required OverlayParams overlayParams});

  void hideSlidingOverlay({String? key});
  void immediateHideOverlay({String? key});

  bool isOverlayIsShown(String key);

  void close();
}
