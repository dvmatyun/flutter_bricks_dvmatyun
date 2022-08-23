import 'package:flutter/material.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_message.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/sliding_overlay/domain/controllers/sliding_overlay_controller.dart';

typedef TypedMessageBuilder = Widget Function(OverlayMessage typedMessage);

abstract class ITopMessageNotificator implements ISlidingOverlayController {}
