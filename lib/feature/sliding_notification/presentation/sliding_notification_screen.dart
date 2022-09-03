import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/common/models/overlay_message.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/common/models/overlay_params.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/common/models/typed_message.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/sliding_overlay/domain/controllers/top_message_notificator.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/sliding_overlay/presentation/controllers/top_message_notificator_impl.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/sliding_overlay/presentation/widgets/notification_message_widget.dart';

/// SlidingNotificationScreen
class SlidingNotificationScreen extends StatefulWidget {
  const SlidingNotificationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SlidingNotificationScreen> createState() => _SlidingNotificationScreenState();
} // SlidingNotificationScreen

/// State for widget SlidingNotificationScreen
class _SlidingNotificationScreenState extends State<SlidingNotificationScreen> {
  ITopMessageNotificator? _topMessageNotificator;

  late final msgStream = Stream<String>.periodic(
    const Duration(milliseconds: 1300),
    ((i) => 'message $i'),
  );
  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _topMessageNotificator = TopMessageNotificatorImpl(
          overlayInsertFunc: (entry) => Overlay.of(context)?.insert(entry),
          typedMessageBuilder: _typedMessageBuilder,
          typedMessageStream: msgStream.map(((event) {
            final message = _mapStringToTypedMsg(event);
            if (_topMessageNotificator!.isOverlayIsShown(overlayParams.key!)) {
              return OverlayMessage(typedMessage: message, overlayParams: overlayParams2);
            }
            return OverlayMessage(typedMessage: message, overlayParams: overlayParams);
            //_mapStringToTypedMsg
          })));
    });
  }

  Widget _typedMessageBuilder(OverlayMessage typedMessage) => NotificationMessageWidget(
        onClose: () => _topMessageNotificator!.hideSlidingOverlay(key: typedMessage.overlayParams.key),
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Text(typedMessage.message),
      );

  late final overlayParams = OverlayParams(
    key: 'top-message-01',
    screenHeight: MediaQuery.of(context).size.height,
    screenWidth: MediaQuery.of(context).size.width,
    overlayHeight: 60,
    overlayWidth: min(MediaQuery.of(context).size.width / 2, 1000),
    topOffset: 10,
    animationDuration: const Duration(milliseconds: 1000),
    overlayStayDuration: const Duration(milliseconds: 2000),
  );

  late final overlayParams2 = overlayParams.copyWith(
    key: 'top-message-02',
    topOffset: (overlayParams.topOffset * 2 + (overlayParams.overlayHeight ?? 0)),
  );

  TypedMessage _mapStringToTypedMsg(String message) => TypedMessage(type: 'simple', message: message);

  @override
  void dispose() {
    sub?.cancel();
    _topMessageNotificator?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'You have pushed the button this many times:',
          ),
          Text(
            'abc',
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }
}
