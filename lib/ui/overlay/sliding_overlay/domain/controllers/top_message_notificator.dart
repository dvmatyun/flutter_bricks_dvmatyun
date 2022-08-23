import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/common/models/overlay_message.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/sliding_overlay/domain/controllers/sliding_overlay_controller.dart';

typedef TypedMessageBuilder = Widget Function(OverlayMessage typedMessage);

abstract class ITopMessageNotificator implements ISlidingOverlayController {}
