import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/common/models/overlay_params.dart';

///https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html

abstract class ISlidingOverlayController {
  void showSlidingOverlayFromTop(Widget child, {String? key, OverlayParams? overlayParams});

  void hideSlidingOverlay({String? key});
  void immediateHideOverlay({String? key});
}
